-- AlterTable
ALTER TABLE `posts` ADD COLUMN `support_count` INTEGER NOT NULL DEFAULT 0;

-- CreateTable
CREATE TABLE `volunteer_supports` (
    `support_id` INTEGER NOT NULL AUTO_INCREMENT,
    `post_id` INTEGER NOT NULL,
    `user_id` INTEGER NOT NULL,
    `supported_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `volunteer_supports_post_id_user_id_key`(`post_id`, `user_id`),
    PRIMARY KEY (`support_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `volunteer_supports` ADD CONSTRAINT `volunteer_supports_post_id_fkey` FOREIGN KEY (`post_id`) REFERENCES `posts`(`post_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `volunteer_supports` ADD CONSTRAINT `volunteer_supports_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
