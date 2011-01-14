package VR::Route::Forum;

use common::sense;
use Dancer ':syntax';
use Dancer::Plugin::Database;

prefix '/forum';


# You need to specify a tag, otherwise redirect to front page
get '/' => sub {
    redirect '/';
};


# Matches tags - multiple tags are separated by a + - the R of CRUD
# splat keyword doesn't seem to work, so have to use it via params.
# This regex matches tags and pages too. A bit fugly, but DRY.
get qr{/([\w+\-]+)/?(\d+)?/?$} => sub {
    my (@tags)  = split(/\+/, params->{splat}[0]);
    my $page    = params->{splat}[1];

    template 'forum';
};


# POST'ing to this url gives us the C-UD of CRUD.
# In practical terms, it's used when creating a new thread and nothing else.
post qr{/([\w+\-]+)/?(\d+)?/?$} => sub {
    my (@tags) = split(/\+/, params->{splat}[0]);
    my $page    = params->{splat}[1];

    redirect '/';
};


true;
