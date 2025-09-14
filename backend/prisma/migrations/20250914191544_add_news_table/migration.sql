-- CreateTable
CREATE TABLE `news` (
    `news_id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(191) NOT NULL,
    `content` TEXT NOT NULL,
    `priority` VARCHAR(191) NOT NULL DEFAULT 'notice',
    `image_url` VARCHAR(191) NULL,
    `image_name` VARCHAR(191) NULL,
    `author_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,
    `is_published` BOOLEAN NOT NULL DEFAULT true,
    `view_count` INTEGER NOT NULL DEFAULT 0,
    `date_time` VARCHAR(191) NULL,
    `disclaimer` VARCHAR(191) NULL,

    PRIMARY KEY (`news_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `news` ADD CONSTRAINT `news_author_id_fkey` FOREIGN KEY (`author_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
