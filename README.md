# Cleve's Computer

A simulated computer app.

This app has a simple interface for editing and executing instructions of a simulated computer. The user enters assembly language-like codes into specific addresses, then clicks on Execute to get the result.

## Instruction set:

MULT: Pop the 2 arguments from the stack, multiply them and push the result back to the stack.
CALL addr: Set the program counter (PC) to addr.
RET: Pop address from stack and set PC to address.
STOP: Exit the program.
PRINT: Pop value from stack and print it.
PUSH arg: Push argument to the stack

## Requirements

ruby 2.3.0p0
Rails 5.0.0.1

## Setup

Open a terminal window and check software versions:

ruby -v
rails --version

Move to home directory and clone the repository:

git clone https://github.com/Indrikoterio/compapp.git

Move into compapp directory:

cd compapp

Install required gems:

bundle install

Initialize database:

rake db:migrate

Start up server:

rails server

Set browser URL to http://localhost:3000/

## Tests

Move to compapp/test and run:

ruby tc_computer

## Cleve Lendon, 2016


