Vegetable Revolution
====================

This is the code that runs [The Vegetable Revolution](http://vegetablerevolution.co.uk). A forum from the old times. The first post was on March 13th 2001 - a 9 digit unix timestamp.

It was written by me when I was still a total amateur coder in the academic 2008-2009 year, with only minor bugfixes. Please keep this in mind when viewing the code. The Git commits don't match up to when it was originally written, as it has been imported, lost, found, moved between repos, and generally screwed up.

In 2014, I decided to updated it a little bit so it could be maintained by others. This involved removing the dependency on SQLite, fixing the numerous security holes (specifically the use of MD5 to hash passwords), and automating the deployment. There are doubtless many, many issues that still remain. But as the website is a ghost town, the code just needs to be stable enough to keep running without exploding. Perhaps someone else can pick up the mantle.

Also note the code in the [Mega-Zine](https://github.com/LoonyPandora/Mega-Zine) repo, which contains a simple representation of the Mega-Zine letters portion of this forum.

This code is released under the MIT license.

Notes:
- Backup of the post database is in the database dir, along with the MySQL schema
- Code is designed to run on Linux, specifically tested on Ubuntu 14.04 LTS, with Perl 5.18.2
- There is no list of dependencies, no good store of Metadata. So grab [Module::Extract::Use](https://metacpan.org/pod/Module::Extract::Use)
- It is tested with MariaDB 10.0.12, using InnoDB.
- It requires nginx, specifically tested with 1.7.3 from the main Ubuntu Repo

Running the forum:
- The system directory contains all the relevant config for MySQL & Nginx.
- There is an init script to start the service. Running ``service vegrev restart`` as required
- Deployment is just git pulling and restarting. There is no DB migration. ``cd /usr/share/nginx/vegetablerevolution/; git pull;``