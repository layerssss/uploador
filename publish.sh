git checkout master
git branch -D heroku
git checkout -b heroku
npm install
bower install
git add components -f
git commit -m '[PUBLISHING]Add components for heroku'
git push heroku heroku:master -f
git checkout master
git branch -D heroku