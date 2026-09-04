-- ---------------------------------------------------------------
-- MiniBank · 04_admin.sql
-- Роль администратора, блокировка пользователей, журнал действий.
--
-- Если MySQL ругается "Duplicate column name" — значит колонка уже
-- добавлена раньше, эту строку можно пропустить.
-- ---------------------------------------------------------------

ALTER TABLE users ADD COLUMN is_admin       TINYINT(1)   NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN is_blocked     TINYINT(1)   NOT NULL DEFAULT 0;
ALTER TABLE users ADD COLUMN blocked_reason VARCHAR(255) NOT NULL DEFAULT '';
ALTER TABLE users ADD COLUMN blocked_at     DATETIME     NULL;

CREATE TABLE IF NOT EXISTS admin_log (
    id          INT AUTO_INCREMENT PRIMARY KEY,
    admin_id    INT             NOT NULL,
    action      VARCHAR(40)     NOT NULL,
    target_type VARCHAR(30)     NOT NULL DEFAULT '',
    target_id   INT             NOT NULL DEFAULT 0,
    details     VARCHAR(255)    NOT NULL DEFAULT '',
    created_at  TIMESTAMP       NOT NULL DEFAULT CURRENT_TIMESTAMP,

    KEY idx_admin_log_admin (admin_id, id)
) ENGINE = InnoDB DEFAULT CHARSET = utf8mb4;

-- Назначить администратором уже зарегистрированного пользователя:
-- UPDATE users SET is_admin = 1 WHERE phone = '77000000000';
