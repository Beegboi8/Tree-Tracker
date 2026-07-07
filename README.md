# Tree Tracker website

The install script should install all dependencies for the server to run

EXCEPT

VS Code is required to forward ports for free so you can expose the site to internet

<hr>

1. Download and install VS Code
2. Download and run tree-site-setup.sh scrip
3. Open the project folder at /srv/tree-backend in VS Code
4. Forward ports 80 and 3000 to the internet with the 'ports' panel in VS Code
5. Make the ports public
6. Go to the terminal and run ```npm start``` to start running the server
7. Go to the link that VS Code assigned to port 80

Viola! Website!
