-- AlterTable
ALTER TABLE `post_media` ADD COLUMN `image_id` INTEGER NULL,
    MODIFY `file_url` VARCHAR(191) NULL;

-- AddForeignKey
ALTER TABLE `post_media` ADD CONSTRAINT `post_media_image_id_fkey` FOREIGN KEY (`image_id`) REFERENCES `images`(`id`) ON DELETE SET NULL ON UPDATE CASCADE;
