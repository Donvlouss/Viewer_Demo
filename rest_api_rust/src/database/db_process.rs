use std::collections::HashMap;
use rusqlite::{Connection, backup};
use crate::*;

pub fn load_db() -> Option<Connection> {
    match Connection::open("path/to/XXX.db")  {
        Err(_) => None,
        Ok(connection) => {
            let mut conn_mem = Connection::open_in_memory().unwrap();
            {
                let backup = backup::Backup::new(&connection, &mut conn_mem).unwrap();
                backup.step(-1).unwrap();
            }
            connection.close().unwrap();
            Some(conn_mem)
        },
    }
}

pub fn close_db(db: Connection) {
    db.close().unwrap();
}

pub fn get_classes(db: &Connection) -> Vec<Class> {
    let mut stmt = db.prepare("SELECT * FROM Class").unwrap();
    stmt.query_map([],
        |row| {
            Ok(
                Class {
                    id: row.get(0)?,
                    name: row.get(1)?,
                    count: row.get(2)?,
                }
            )
        }
    ).unwrap().map(|x| x.unwrap()).collect()
}

pub fn get_tag_names(db: &Connection, tag: TagConfig) -> Vec<String> {
    let mut stmt = db.prepare(
        format!("SELECT Text FROM {}", tag).as_str())
        .unwrap();
    stmt.query_map([],
        |row| {
            row.get(0)
        }
    ).unwrap().map(|x| x.unwrap()).collect()
}

pub fn get_books_shallow_config(db: &Connection) -> Vec<BookConfig> {
    let classes = get_classes(db);
    let mut stmt = db.prepare("SELECT * FROM Book").unwrap();
    stmt.query_map([],
        |row| {
            Ok(
                BookConfig::new(
                    row.get(0)?,
                    row.get(2)?,
                    classes[row.get::<usize, usize>(1)? - 1].name.clone(),
                    row.get(3)?,
                    row.get(4)?,
                )
            )
        }
    ).unwrap().map(|x| x.unwrap()).collect()
}

pub fn get_books_shallow_map(db: &Connection) -> HashMap<u64, BookConfig> {
    let classes = get_classes(db);
    let mut stmt = db.prepare("SELECT * FROM Book").unwrap();
    stmt.query_map([],
        |row| {
            Ok(
                (row.get(0)?,
                    BookConfig::new(
                        row.get(0)?,
                        row.get(2)?,
                        classes[row.get::<usize, usize>(1)? - 1].name.clone(),
                        row.get(3)?,
                        row.get(4)?,
                        )
                )
            )
        }
    ).unwrap().map(|x| x.unwrap()).collect()
}

pub fn get_tag_linked_index(db: &Connection, tag: TagConfig, id: u64) -> Vec<u64> {
    let mut stmt = db.prepare(
        format!(r#"SELECT TagId FROM {}_Link WHERE BookId={}"#, tag, id).as_str()
    ).unwrap();

    stmt.query_map([], 
        |row| {
            row.get(0)
        }
    ).unwrap().map(|x| x.unwrap()).collect()
}

pub fn get_uid_from_url(url: String) -> String {
    url.split("/").collect::<Vec<&str>>()
        .iter().rev().skip(1).take(2).rev()
        .map(|s| String::from(*s)).collect::<Vec<String>>().join("-")
}

pub fn query_tags_with_arg(db: &Connection, arg: String) -> Vec<u64> {
    let mut stmt = db.prepare(arg.as_str()).unwrap();
    stmt.query_map([],
        |row| {
            row.get(0)
        }
    ).unwrap().map(|x| x.unwrap()).collect::<Vec<u64>>()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_load_close() {
        match load_db()  {
            None => assert!(false, "Open Error"),
            Some(db) => close_db(db),
        }
    }

    #[test]
    fn test_get_classes() {
        match load_db()   {
            None => assert!(false, "Open Error"),
            Some(db) => {
                let classes = get_classes(&db);
                close_db(db);
                assert_eq!(classes.len(), 10);
            },
        }
    }

    #[test]
    fn test_get_tag_names() {
        match load_db() {
            None => assert!(false, "Open Error"),
            Some(db) => {
                let tag_names = get_tag_names(&db, TagConfig::Language);
                close_db(db);
                assert_eq!(tag_names.len(), 13);
            },
        }
    }

    #[test]
    fn test_get_books_shallow_config() {
        match load_db() {
            None => assert!(false, "Open Error"),
            Some(db) => {
                let books = get_books_shallow_map(&db);
                close_db(db);
                assert_eq!(books.len(), 65948);
            },
        }
    }

    #[test]
    fn test_get_linked_index() {
        let _book = BookConfig::new(29991, "".to_string(), "".to_string(), 0, "".to_string());

        match load_db() {
            None => assert!(false, "Open Error"),
            Some(db) => {
                let linked = get_tag_linked_index(&db, TagConfig::Female, 29991);
                close_db(db);
                assert_eq!(linked.len(), 35);
            },
        }
    }

    #[test]
    fn test_database() {
        let mut db = DataBase::new();
        let _book = db.get_book_data(29991);
        // println!("{:?}", book);

        assert!(true)
    }
}