.. _debian-packages:

Debian Packages
***************

Add repository key::

    wget http://repo.ajenti.org/debian/key -O- | apt-key add -

Add repository to /etc/apt/sources.list::
    
    echo "deb http://repo.ajenti.org/ng/debian main main" >> /etc/apt/sources.list

Install the package::
    
    apt-get update && apt-get install ajenti

Start the service::
    
    service ajenti restart
