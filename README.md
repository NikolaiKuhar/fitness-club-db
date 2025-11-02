# Fitness Club Database (ERD + SQL)

Учебный проект по дисциплине *Relational Databases*.

## Содержимое
- `erd/fitness_club_erd.png` — логическая схема (ERD)  
- `erd/fitness_club_erd1.png` — исходник Mermaid (опционально)  
- `sql/schema.sql` — DDL (создание схемы `fit`, PK/FK/UNIQUE/CHECK, индексы)  
- `sql/seed.sql` — тестовые данные и примерные запросы (опционально)  
- `docs/fitness_club_ERD_description.txt` — текстовое описания диаграммы

## Быстрый старт (PostgreSQL)
```sql
-- запусти в своей БД (pgAdmin → Query Tool)
\i sql/schema.sql
-- по желанию
\i sql/seed.sql
