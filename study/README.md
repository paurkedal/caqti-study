---
sidebar_position: 1
hide_table_of_contents: true
# displayed_sidebar: "wat"
# sidebar_custom_props: {hideable: true,collapsed: true}
---


# Getting Started

Welcome to the Caqti study!

## What we will be building

We will learn to handle this mildly complex relationship with `Caqti` and `PostgreSQL`:

```mermaid
erDiagram
    AUTHOR one to one or many BIBLIOGRAPHY : ""
    AUTHOR {
        int id PK
        string first_name "NOT NULL"
        string middle_name "NULL"
        string last_name "NOT NULL"
    }
    BOOK one to one or many BIBLIOGRAPHY : ""
    BOOK {
        int id PK
        string title "NOT NULL"
        string description "NOT NULL"
        string isbn "NOT NULL UNIQUE"
        date published_on "NOT NULL"
    }
    BIBLIOGRAPHY {
        int author_id FK
        int book_id FK
    }
```

- an author can publish one or many books
- a book can be written by one or many authors
