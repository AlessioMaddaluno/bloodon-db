# bloodon-db
A full designed DB project for a fictitious blood donation organization.

This repository contains my university databse exam project, made with my colleague [Francesco Palumbo](https://github.com/FrancescoPalumbo "Francesco Palumbo") a few years ago.

The project is based on **Oracle DBMS**.

Directories, files and documentation are written in italian.

- The folder "docs" contains the full documentation of the database design including some context and explanation of implementation choices.
- The foder "code" contains the source code inclunding an handy script for building and populating the db automatically. (QUICK_BUILD.sql)


## Installation

- Clone the repository;
- Login as admin's DMBS (sys)  and run the script "INIT.sql";
- Login as the user "blodon" (default password: 123) and run the script "BUILD-DB.sql"

It creates all the entities, triggers, stored procedures and the database will be filled with some dummy data.
