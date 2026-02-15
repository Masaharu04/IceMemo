protocol PhotoUseCase {
    func save(image: UIImage, expiration: Expiration) -> URL?
    func fetch() -> [URL]
}

final class PhotoUseCaseImpl: PhotoUseCase {

    func save(
        image: UIImage,
        expiration: Expiration
    ) -> URL? {
        let url = makeUrl(expiration: expiration)
        guard let data = image.jpegData(compressionQuality: 0.5) else {
            return nil
        }
        savePhoto(data: data, url: url)
        return url
    }
}
