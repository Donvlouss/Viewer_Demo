use std::{collections::HashMap, sync::Arc};
use std::str::FromStr;

use parking_lot::{RwLock, Mutex};
use strum;
use rusqlite::Connection;
use serde::{Serialize, Deserialize};


#[derive(Debug, Clone, PartialEq, Eq)]
pub struct Class {
    pub id: u8,
    pub name: String,
    pub count: u32,
}

#[derive(Debug, Clone, strum::EnumString, strum::Display, PartialEq, Eq)]
pub enum TagConfig {
    #[strum(serialize = "Class", serialize = "t")]
    Class,
    #[strum(serialize = "Language", serialize = "l")]
    Language,
    #[strum(serialize = "Parody", serialize = "p")]
    Parody,
    #[strum(serialize = "Character", serialize = "c")]
    Character,
    #[strum(serialize = "Group_", serialize = "g")]
    Group_,
    #[strum(serialize = "Artist", serialize = "a")]
    Artist,
    #[strum(serialize = "Male", serialize = "m")]
    Male,
    #[strum(serialize = "Female", serialize = "f")]
    Female,
    #[strum(serialize = "Other", serialize = "o")]
    Other,
}

#[derive(Debug, Clone, PartialEq, Eq, Deserialize, Serialize)]
pub struct BookConfig {
    pub id: u64,
    pub title: String,
    pub class: String,
    pub pages: u32,
    pub page_list: Vec<String>,
    pub url: String,
    pub language: Vec<String>,
    pub parody: Vec<String>,
    pub character: Vec<String>,
    pub group: Vec<String>,
    pub artist: Vec<String>,
    pub male: Vec<String>,
    pub female: Vec<String>,
    pub other: Vec<String>,
    pub is_searched: bool,
}

impl BookConfig {
    pub fn none() -> Self {
        BookConfig {
            id: 0, title: "".to_string(), class: "".to_string(),
            pages: 0, page_list: vec![], url: "".to_string(), language: vec![], parody: vec![],
            character: vec![], group: vec![], artist: vec![], male: vec![], female: vec![],
            other: vec![], is_searched: false
        }
    }

    pub fn new(id: u64, title: String, class: String, pages: u32, url: String) -> Self {
        BookConfig { 
            id, title, class, pages, page_list: vec![], url,
            language: vec![], parody: vec![], character: vec![],
            group: vec![], artist: vec![], male: vec![], female: vec![],
            other: vec![], is_searched: false
        }
    }

    pub fn get_index_page_path(&self, index: u32) -> String {
        format!("path/to/{}/{}/{}", self.class, crate::get_uid_from_url(self.url.clone()), self.page_list[index as usize])
    }
}
pub type Book = HashMap<u64, BookConfig>;

#[derive(Debug)]
pub struct DataBase {
    pub db: Arc<Mutex<Connection>>,

    // books: HashMap<u64, BookConfig>,
    pub books: Arc<RwLock<Book>>,
    
    pub class: Vec<String>,
    pub language: Vec<String>,
    pub parody: Vec<String>,
    pub character: Vec<String>,
    pub group: Vec<String>,
    pub artist: Vec<String>,
    pub male: Vec<String>,
    pub female: Vec<String>,
    pub other: Vec<String>,
}

impl DataBase {
    pub fn new () -> Self {
        match crate::load_db() {
            None => panic!("Database not found!"),
            Some(db) => DataBase{
                books: Arc::new(RwLock::new(crate::get_books_shallow_map(&db))),
                class: crate::get_classes(&db).iter().map(|c| c.name.clone()).collect::<Vec<String>>(),
                language: crate::get_tag_names(&db, TagConfig::Language),
                parody: crate::get_tag_names(&db, TagConfig::Parody),
                character: crate::get_tag_names(&db, TagConfig::Character),
                group: crate::get_tag_names(&db, TagConfig::Group_),
                artist: crate::get_tag_names(&db, TagConfig::Artist),
                male: crate::get_tag_names(&db, TagConfig::Male),
                female: crate::get_tag_names(&db, TagConfig::Female),
                other: crate::get_tag_names(&db, TagConfig::Other),
                db: Arc::new(Mutex::new(db))
            },
        }
    }

    pub async fn get_book_data(&mut self, id: u64) -> BookConfig {
        // let mut book = self.books.get_mut(&id).unwrap();
        let binding = self.books.read();
        let mut book = binding.get(&id).unwrap().clone();
        drop(binding);

        if book.is_searched{
            return book.clone();
        }

        {
            let locked_db = self.db.lock();
            book.page_list = crate::get_images_from_folder(book.class.clone(), crate::get_uid_from_url(book.url.clone()))
                .iter().map(|f| f.split("/").last().unwrap().to_string()).collect::<Vec<String>>();
            book.language = crate::get_tag_linked_index(&locked_db, TagConfig::Language, book.id)
                .iter().map(|i| self.language[*i as usize - 1].clone()).collect();
            book.parody = crate::get_tag_linked_index(&locked_db, TagConfig::Parody, book.id)
                .iter().map(|i| self.parody[*i as usize - 1].clone()).collect();
            book.character = crate::get_tag_linked_index(&locked_db, TagConfig::Character, book.id)
                .iter().map(|i| self.character[*i as usize - 1].clone()).collect();
            book.group = crate::get_tag_linked_index(&locked_db, TagConfig::Group_, book.id)
                .iter().map(|i| self.group[*i as usize - 1].clone()).collect();
            book.artist = crate::get_tag_linked_index(&locked_db, TagConfig::Artist, book.id)
                .iter().map(|i| self.artist[*i as usize - 1].clone()).collect();
            book.male = crate::get_tag_linked_index(&locked_db, TagConfig::Male, book.id)
                .iter().map(|i| self.male[*i as usize - 1].clone()).collect();
            book.female = crate::get_tag_linked_index(&locked_db, TagConfig::Female, book.id)
                .iter().map(|i| self.female[*i as usize - 1].clone()).collect();
            book.other = crate::get_tag_linked_index(&locked_db, TagConfig::Other, book.id)
                .iter().map(|i| self.other[*i as usize - 1].clone()).collect();
            book.is_searched = true;
        }
        self.books.write().insert(id, book.clone());

        book
    }
}

#[derive(Debug, Deserialize, Serialize)]
pub struct QueryModel {
    pub name: String,
    pub value: String,
}

impl QueryModel {
    pub fn str(&self) -> String {
        let mut id: usize = 0;
        let mut is_class = false;
        unsafe {

            let _ = match TagConfig::from_str(&self.name).unwrap() {
                TagConfig::Class => {
                    is_class = true;
                    &crate::S_DATA_BASE.class
                },
                TagConfig::Language => &crate::S_DATA_BASE.language,
                TagConfig::Parody => &crate::S_DATA_BASE.parody,
                TagConfig::Character => &crate::S_DATA_BASE.character,
                TagConfig::Group_ => &crate::S_DATA_BASE.group,
                TagConfig::Artist => &crate::S_DATA_BASE.artist,
                TagConfig::Male => &crate::S_DATA_BASE.male,
                TagConfig::Female => &crate::S_DATA_BASE.female,
                TagConfig::Other => &crate::S_DATA_BASE.other,
            }.into_iter().enumerate().for_each(|(i, s)| {
                if &self.value == s {
                    id = i + 1;
                }
            });
        }

        if is_class {
            return format!("SELECT Idx FROM Book WHERE Class = {}", id);
        }
        format!("SELECT BookId FROM {}_Link WHERE TagId = {}", self.name, id)
    }
}