use warp::Filter;
use rest_api_rust::*;

#[tokio::main]
async fn main() {
    println!("Hello, world!");

    let routes = crate::get_book_config_route()
        .or(crate::get_book_shallow_config_route())
        .or(crate::get_book_image_route())
        .or(crate::get_tag_list_route())
        .or(crate::get_books_list_route())
        .or(crate::get_query_result());

    warp::serve(routes)
        .run(([0, 0, 0, 0], 3031))
        .await;
}
