use std::fs;
use std::io::prelude::*;
use std::io::Read;
use flate2::Compression;
use flate2::write::GzEncoder;

pub fn get_images_from_folder(class: String, uid: String) -> Vec<String> {
    get_images_from_folder_(format!("path/to/{}/{}", class, uid))
}

fn get_images_from_folder_(path: String) -> Vec<String> {
    match fs::read_dir(path) {
        Err(_) => Vec::new(),
        Ok(entries) => {
            entries.filter_map(|entry| {
                entry.ok().and_then(|e| {
                    e.path().to_str().map(|s| s.to_string().replace("\\", "/"))
                    })
                }   
            ).collect()
        },
    }
}

pub fn get_encoded_image(path: String) -> (usize, Vec<u8>) {
    let mut file = fs::File::open(path)
        .expect("Failed to open file");
    let mut buf = Vec::<u8>::new();
    file.read_to_end(&mut buf)
        .expect("Failed to read file");

    (buf.len(), buf)
}

pub fn encode_u8_list(list: Vec<u8>) -> Vec<u8> {
    let buf:&[u8] = &list;
    let mut e = GzEncoder::new(Vec::new(), Compression::default());
    e.write_all(buf).unwrap();
    e.finish().unwrap()
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn get_test_folder() {
        let path = String::from("path/to/book");
        let images = get_images_from_folder_(path);
        for img in &images {
            println!("{}", img.split("/").last().unwrap());
        }
        assert_eq!(images.len(), 85)
    }

    #[test]
    fn get_test_folder_src() {
        let class = String::from("Favorites_9");
        let uui = String::from("317118-1b847e13d5");
        let images = get_images_from_folder(class, uui);
        assert_eq!(images.len(), 191)
    }

    #[test]
    fn get_encoded_image_test() {
        let img = String::from("path/to/book/01.JPG");
        let (data, _ret) = get_encoded_image(img);
        assert_eq!(data, 50734)
    }

    #[test]
    fn get_encoded_image_test_src() {
        let img = String::from("path/to/book/01.JPG");
        let (data, ret) = get_encoded_image(img);
        let _out = encode_u8_list(ret);
        assert_eq!(data, 50734)
    }
}