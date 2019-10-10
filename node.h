#include <string>
#include <iostream>

class Node
{
  public:
    std::string name;
    Node *left, *right, *third, *fourth;
    Node(std::string name) : name(name), left(0), right(0), third(0), fourth(0) {}
    Node(std::string name, Node *left) : name(name), left(left), right(0), third(0), fourth(0) {}
    Node(std::string name, Node *left, Node *right) : name(name), left(left), right(right), third(0), fourth(0) {}
    Node(std::string name, Node *left, Node *right, Node *third) : name(name), left(left), right(right), third(third), fourth(0) {}
    Node(std::string name, Node *left, Node *right, Node *third, Node *fourth) : name(name), left(left), right(right), third(third), fourth(fourth) {}
};