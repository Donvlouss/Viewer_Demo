pub mod image {
    pub mod book_process;
}
pub use crate::image::book_process::*;

pub mod database {
    pub mod db_models;
    pub mod db_process;
}
pub use crate::database::db_models::*;
pub use crate::database::db_process::*;

pub mod routes {
    pub mod core;
    pub mod routes;
}
pub use crate::routes::core::*;
pub use crate::routes::routes::*;


pub use once_cell::sync::Lazy;
pub static mut S_DATA_BASE: Lazy<DataBase> = Lazy::new(|| DataBase::new());