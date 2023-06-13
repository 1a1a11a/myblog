# Instructions on writing a new blog
## Setup
The easiest way is to use GitHub Codespace to create an environemnt to write and deploy. 
Alternatively, we can download to local and setup locally, but do note that the website has a lot of small files, so do not place in an synchronized environment, e.g., Dropbox. And setting up `jekyll` sometimes can be tricky due to version problem.

No matter where the repo is, take a look at the [run.sh](run.sh) for how to install dependency and start the web server. 

```bash
# set up the dependency
bundle install

# run the web server 
bundle exec jekyll serve --watch --host 0.0.0.0 --safe
```

## Add a new blog
### Step 1: add a markdown file under [_posts](_posts)

### Step 2: store static media under assets
Create a folder for each blog



