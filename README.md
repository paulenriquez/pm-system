# Petron Bagumbayan Service Station - Decision Support System

A capstone project by Kanri Solutions, AdMU BS MIS 2018
* Enriquez, Paul
* Reyes, Jego
* Seechung, Vito
* Tiongson, Dani
* Triaca, Miguel

Commissioned by Mr. Emmanuel Puno, Owner and Proprietor of the Petron Bagumbayan Service Station in Quezon City, NCR.

## Required Platform
This is a web-based application written in <b>Ruby on Rails</b>.
* Rails version 5.0.6, Ruby version 2.3.3
* PostgreSQL 10.1

### Dependencies
Listed below are the gems (Ruby libraries) that is used by the system.

| Gem                              | Version    | Description                    |
| -------------------------------- | ---------- | ------------------------------ |
| rails                            | 5.0.6      |                                |
| pg                               | 0.21.0     |                                |
| puma                             | 0.21.0     | Rails web server               |
| sass-rails                       | 5.0        | SASS Preprocessor              |
| uglifier                         | 1.3.0      | JS minification tool           |
| jquery-rails                     | 4.3.1      | jQuery library                 |
| jbuilder                         | 2.5        | JSON builder                   |
| bootstrap                        | 4.0.0      | Bootstrap CSS Library          |
| vuejs-rails                      | 2.4.2      | VueJS JS Library               |
| simple_form                      | 3.3.1      | Simple Forms form builder      |
| cocoon                           | 1.2.11     | Nested forms builder           |
| devise                           | 4.4.1      | Authentication library         |
| bootstrap4-datetime-picker-rails | 0.1.5      | Date/Time Picker library       |
| chartkick                        | 2.3.4      | Chart generation library       |
| groupdate                        | 4.0.0      | <em>*Chartkick dependency</em> |
| render_async                     | 1.2.0      | Asynchronous rendering library |


## Installation

Make sure that Rails and PostgreSQL are properly installed.

Ensure that the required dependencies have been set up in the Gemfile.
If so, run
```
bundle install
```

Navigate to the system's directory, open database.yml, and type
```
default: &default
  adapter: postgresql
  pool: 5
  encoding: 'utf-8'
  timeout: 5000
  username: { PostgreSQL Username }
  password: { PostgreSQL Password }

development:
  <<: *default
  database: pm_system_development

test:
  <<: *default
  database: pm_system_test

production:
  <<: *default
  database: pm_system_production
```

Then, in the console, run the ff:
```
rails db:create
rails db:migrate
rails db:seed
```

Finally, run
```
rails s
```
to start the server. Navigate to `localhost:3000` to check if the server is properly running.