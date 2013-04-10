
# Demonstration for Slow uploading on Heroku Cedar stack with Unicorn

Push to Heroku and try it with:

    ./bench http://your-app.herokuapp.com

Then switch to `Rainbows!` with `EventMachine` by changing `Procfile` with
`sed s/unicorn/rainbows/g Procfile`, pushing to Heroku and try again:

    ./bench http://your-app.herokuapp.com
