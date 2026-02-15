import UIKit

final class PhotoCapturedUseCase {

    private let photoUseCase: PhotoUseCase
    private let notificationUseCase: ScheduleDeleteNoticeForPhotoUseCase

    init(
        photoUseCase: PhotoUseCase,
        notificationUseCase: ScheduleDeleteNoticeForPhotoUseCase
    ) {
        self.photoUseCase = photoUseCase
        self.notificationUseCase = notificationUseCase
    }

    func execute(
        image: UIImage,
        expiration: Expiration
    ) {
        guard let photoURL = photoUseCase.save(
            image: image,
            expiration: expiration
        ) else {
            return
        }

        notificationUseCase.execute(
            expiration: expiration,
            photoURL: photoURL
        )
    }
}
