#pragma once

typedef struct Node Node;

void printList(Node* head);
void createNode(Node* head, char * name, char * command);
bool deleteNode(Node* head, char * name);