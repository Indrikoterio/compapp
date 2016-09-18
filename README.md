# README

Simulated computer app.

This app has a simple interface for editing and executing instructions of a simulated computer.
The user enters assembly language-like codes into specific addresses, then clicks on execute to get the result.

Instruction set:

MULT: Pop the 2 arguments from the stack, multiply them and push the result back to the stack.
CALL addr: Set the program counter (PC) to addr.
RET: Pop address from stack and set PC to address.
STOP: Exit the program.
PRINT: Pop value from stack and print it.
PUSH arg: Push argument to the stack


Cleve Lendon 2016

Things you may want to cover:

* Ruby version

ruby 2.3.0p0
Rails 5.0.0.1


* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...
