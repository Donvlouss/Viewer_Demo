use std::str::FromStr;
use warp::http;
use warp::hyper::Body;

use crate::{QueryModel, TagConfig};

pub async fn get_book_config(id: u64) -> Result<impl warp::Reply, warp::Rejection> {
    println!("UID= {}", id);
    unsafe
    {
        let result = &crate::S_DATA_BASE.get_book_data(id).await;
        Ok(warp::reply::json(&result.clone()))
    }
}

pub async fn get_book_shallow_config(id: u64) -> Result<impl warp::Reply, warp::Rejection> {
    unsafe {
        let binding = &crate::S_DATA_BASE.books.read();
        let result = binding.get(&id).unwrap();
        drop(binding);
        Ok(warp::reply::json(&result.clone()))
    }
}

pub async fn get_book_image(id: u64, page: u32) -> Result<impl warp::Reply, warp::Rejection> {
    println!("UID= {} Page= {}", id, page);
    unsafe {
        let result = &crate::S_DATA_BASE.get_book_data(id).await;
        let img = crate::get_encoded_image(result.get_index_page_path(page)).1;
        Ok(
            http::Response::builder()
            .header("content-type", "image/gif")
            .body(Body::from(img))
            .unwrap()
        )
    }
}

pub async fn get_tag_list(tag: String) -> Result<impl warp::Reply, warp::Rejection> {
    unsafe {
        if let Ok(tag_config) = crate::TagConfig::from_str(&tag) {
            Ok(warp::reply::json(match tag_config {
                TagConfig::Class => &crate::S_DATA_BASE.class,
                TagConfig::Language => &crate::S_DATA_BASE.language,
                TagConfig::Parody => &crate::S_DATA_BASE.parody,
                TagConfig::Character => &crate::S_DATA_BASE.character,
                TagConfig::Group_ => &crate::S_DATA_BASE.group,
                TagConfig::Artist => &crate::S_DATA_BASE.artist,
                TagConfig::Male => &crate::S_DATA_BASE.male,
                TagConfig::Female => &crate::S_DATA_BASE.female,
                TagConfig::Other => &crate::S_DATA_BASE.other,
            }))
        } else {
            Err(warp::reject())
        }
    }
}

pub async fn get_books_list() -> Result<impl warp::Reply, warp::Rejection> {
    unsafe {
        Ok(
            warp::reply::json(
                &crate::S_DATA_BASE.books.read().keys().into_iter().map(|x| *x).collect::<Vec<u64>>()
            )
        )
    }
}

pub async fn query_tags(filters: Vec<QueryModel>) -> Result<impl warp::Reply, warp::Rejection> {
    unsafe {
        Ok(
            warp::reply::json(
                &crate::query_tags_with_arg(
                        &(crate::S_DATA_BASE.db.lock()),
                    filters.iter().map(|f| {
                        f.str()
                    }).collect::<Vec<String>>().join(" UNION ")
                )
            )
        )
    }
}