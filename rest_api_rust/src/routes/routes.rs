use crate::*;
use warp::Filter;


pub fn get_book_config_route() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    warp::path!("book" / u64)
        .and(warp::get())
        .and_then(get_book_config)
}

pub fn get_book_shallow_config_route() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    warp::path!("book" / u64 / "shallow")
        .and(warp::get())
        .and_then(get_book_shallow_config)
}

pub fn get_book_image_route() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    warp::path!("book" / u64 / u32)
        .and(warp::get())
        .and_then(get_book_image)
}

pub fn get_tag_list_route() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    warp::path!("tag" / String)
        .and(warp::get())
        .and_then(get_tag_list)
}

pub fn get_books_list_route() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    warp::path!("books")
        .and(warp::get())
        .and_then(get_books_list)
}

pub fn get_query_result() -> impl Filter<Extract = impl warp::Reply, Error = warp::Rejection> + Clone {
    warp::path!("search")
        .and(warp::post())
        .and(warp::body::json())
        .and_then(query_tags)
}