#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>
#include "linkedlist.h"

struct Node {
    char* name; 
    char* command;
    struct Node* next;
};

void printList(Node* head)
{
    //Make a temp node as to not modify the head
    Node* tempNode = head;

    //Traverse through the list and print the name alias and command
    while(tempNode != NULL)
    {
        printf("Alias: %s Command: %s\n", tempNode->name, tempNode->command);
        tempNode = tempNode->next;
    }    
}

void createNode(Node* head, char * name, char * command)
{
    //Allocate space for a new node
    Node* newNode = malloc(sizeof(Node));
    
    //Assign the new Node name and command with the passed in arguments
    newNode->name = name;
    newNode->command = command;
    newNode->next = NULL;
    
    //If the list is empty, add new node and make it the head of the list
    if(head == NULL)
    {
        head = newNode;
    }
    //Make temp not as to not modify the head
    else {
        Node* tempNode = head;
        //Traverse through the list until we reach the end
        while (tempNode->next != NULL)
        {
            tempNode = tempNode->next;
        }
        //Link the new node to the list
        tempNode->next = newNode;
    }
}

bool deleteNode(Node* head, char * name)
{
    // Make a temp and prev to keep track
    Node* temp = head;
    Node* prev = temp;

    // Keep going till null
    while(temp != NULL)
    {
        // If we find the node we're looking for
        if(temp->name == name)
        {
            prev->next = temp->next;

            // If the node found happens to be the head
            if(temp == head)
            {
                head = temp->next;
            }

            // Make sure to free the space and return true
            free(temp);
            return true;
        }
        prev = temp;
        temp = temp->next;
    }

    // Nothing was found return false
    return false;
}

//Debugging
void main()
{
    Node* linkedList = NULL;

    createNode(linkedList, "beetle", "beetle juice");
    createNode(linkedList, "hello", "hello world");
    createNode(linkedList, "updog", "what's updog?");   
    printList(linkedList);

    deleteNode(linkedList, "hello");
    printList(linkedList);
    
    deleteNode(linkedList, "beetle");
    printList(linkedList);

    deleteNode(linkedList, "updog");
    printList(linkedList);
}