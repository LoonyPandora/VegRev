#!/usr/bin/env perl

# Use vendor libs in preference to system defaults
use lib 'vendor/Dancer/lib';
use lib 'vendor/Dancer-Template-MojoTemplate/lib';

use Dancer;
use VR;

dance;
