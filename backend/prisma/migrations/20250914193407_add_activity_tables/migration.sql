-- CreateTable
CREATE TABLE `activities` (
    `activity_id` INTEGER NOT NULL AUTO_INCREMENT,
    `title` VARCHAR(191) NOT NULL,
    `description` TEXT NOT NULL,
    `date` VARCHAR(191) NOT NULL,
    `time` VARCHAR(191) NOT NULL,
    `place` VARCHAR(191) NOT NULL,
    `location` VARCHAR(191) NULL,
    `latitude` DOUBLE NULL,
    `longitude` DOUBLE NULL,
    `capacity` INTEGER NOT NULL DEFAULT 1,
    `joined` INTEGER NOT NULL DEFAULT 0,
    `comments` INTEGER NOT NULL DEFAULT 0,
    `views` INTEGER NOT NULL DEFAULT 0,
    `image_url` VARCHAR(191) NULL,
    `image_name` VARCHAR(191) NULL,
    `author_id` INTEGER NOT NULL,
    `created_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),
    `updated_at` DATETIME(3) NOT NULL,
    `is_active` BOOLEAN NOT NULL DEFAULT true,
    `end_time` VARCHAR(191) NULL,
    `category` VARCHAR(191) NULL,

    PRIMARY KEY (`activity_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- CreateTable
CREATE TABLE `activity_joins` (
    `join_id` INTEGER NOT NULL AUTO_INCREMENT,
    `activity_id` INTEGER NOT NULL,
    `user_id` INTEGER NOT NULL,
    `joined_at` DATETIME(3) NOT NULL DEFAULT CURRENT_TIMESTAMP(3),

    UNIQUE INDEX `activity_joins_activity_id_user_id_key`(`activity_id`, `user_id`),
    PRIMARY KEY (`join_id`)
) DEFAULT CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- AddForeignKey
ALTER TABLE `activities` ADD CONSTRAINT `activities_author_id_fkey` FOREIGN KEY (`author_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `activity_joins` ADD CONSTRAINT `activity_joins_activity_id_fkey` FOREIGN KEY (`activity_id`) REFERENCES `activities`(`activity_id`) ON DELETE CASCADE ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE `activity_joins` ADD CONSTRAINT `activity_joins_user_id_fkey` FOREIGN KEY (`user_id`) REFERENCES `users`(`user_id`) ON DELETE CASCADE ON UPDATE CASCADE;
