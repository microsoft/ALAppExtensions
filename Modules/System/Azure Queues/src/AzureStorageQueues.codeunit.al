/// <summary>
/// Provides helper functions for working with Azure Storage Queues
/// Reference: https://docs.microsoft.com/en-us/rest/api/storageservices/queue-service-rest-api
/// </summary>
codeunit 50100 "Azure Storage Queues Mgt."
{
    Access = Public;

    /// <summary>
    /// Lists all the queues in a storage account
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <returns>List of queues names in the storage account.</returns>
    procedure ListQueues(StorageAccountName: Text): List of [Text]
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.ListQueues(StorageAccountName));
    end;

    /// <summary>   
    /// Creates an Azure Storage Queue
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <returns>TRUE if the queue is succesfully created, FALSE otherwise.</returns>
    procedure CreateQueue(StorageAccountName: Text; Queue: Text): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.CreateQueue(StorageAccountName, Queue));
    end;

    /// <summary>
    /// Deletes a queue in a storage account
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>
    /// <returns>TRUE if the queue is successfully deleted, FALSE otherwise.</returns>
    procedure DeleteQueue(StorageAccountName: Text; Queue: Text): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.DeleteQueue(StorageAccountName, Queue));
    end;

    /// <summary>
    /// Checks is a queue exists in a storage account
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>
    /// <returns>TRUE if the queue exists, FALSE otherwise.</returns>
    procedure CheckIfQueueExists(StorageAccountName: Text; Queue: Text): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.CheckIfQueueExists(StorageAccountName, Queue));
    end;

    /// <summary>
    /// Posts a message on a queue
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>
    /// <param name="MessageBody">Body of the message.</param>
    /// <returns>TRUE if the message is inserted into the queue, FALSE otherwise.</returns>
    procedure PostMessageToQueue(StorageAccountName: Text; Queue: Text; MessageBody: Text): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.PostMessageToQueue(StorageAccountName, Queue, MessageBody));
    end;

    /// <summary>
    /// Updates a message on a queue
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>
    /// <param name="MessageId">ID of the message to update.</param>
    /// <param name="PopReceipt">PopReceipt of the message to update.</param>
    /// <param name="NewMessageBody">New body of the message to update.</param>
    /// <returns>TRUE if the message content is updated, FALSE otherwise.</returns>
    procedure UpdateMessageToQueue(StorageAccountName: Text; Queue: Text; MessageId: Text; PopReceipt: Text; NewMessageBody: Text): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.UpdateMessageToQueue(StorageAccountName, Queue, MessageId, PopReceipt, NewMessageBody));
    end;

    /// <summary>
    /// Retrieves a message from a queue
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>    
    /// <returns>The XML body of the message response from the queue (ref: https://docs.microsoft.com/en-us/rest/api/storageservices/get-messages).</returns>
    procedure GetNextMessageFromQueue(StorageAccountName: Text; Queue: Text[20]): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.GetNextMessageFromQueue(StorageAccountName, Queue));
    end;

    /// <summary>
    /// Peeks a message on a queue (the peek operation retrieves one or more messages from the front of the queue, 
    /// but does not alter the visibility of the message.)
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>    
    /// <returns>The XML body of the message response from the queue (ref: https://docs.microsoft.com/en-us/rest/api/storageservices/get-messages).</returns>
    procedure PeekNextMessageFromQueue(StorageAccountName: Text; Queue: Text[20]): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.PeekNextMessageFromQueue(StorageAccountName, Queue));
    end;

    /// <summary>
    /// Gets the Message ID from the Message XML
    /// </summary>    
    /// <param name="ResponseBody">XML body of the queue message.</param>    
    /// <returns>ID of the message in the queue.</returns>
    procedure GetMessageId(var ResponseBody: Text): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.GetMessageIdFromResponseBody(ResponseBody));
    end;

    /// <summary>
    /// Gets the Message content from the Message XML
    /// </summary>    
    /// <param name="ResponseBody">XML body of the queue message.</param>    
    /// <returns>Content of the message in the queue.</returns>
    procedure GetMessageText(var ResponseBody: Text): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.GetMessageTextFromResponseBody(ResponseBody));
    end;

    /// <summary>
    /// Gets the Message PopReceipt parameter from the Message XML
    /// </summary>    
    /// <param name="ResponseBody">XML body of the queue message.</param>    
    /// <returns>PopReceipt parameter value of the message in the queue.</returns>    
    procedure GetMessagePopReceipt(var ResponseBody: Text): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.GetMessagePopReceiptFromResponseBody(ResponseBody));
    end;

    /// <summary>
    /// Gets the Message insertion time parameter from the Message XML
    /// </summary>    
    /// <param name="ResponseBody">XML body of the queue message.</param>    
    /// <returns>Insertion time parameter value of the message in the queue.</returns>  
    procedure GetMessageInsertionTimeText(var ResponseBody: Text): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.GetMessageInsertionTimeFromResponseBody(ResponseBody));
    end;

    /// <summary>
    /// Gets the Message expiration time parameter from the Message XML
    /// </summary>    
    /// <param name="ResponseBody">XML body of the queue message.</param>    
    /// <returns>Expiration time parameter value of the message in the queue.</returns>  
    procedure GetMessageExpirationTimeText(var ResponseBody: Text): Text
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.GetMessageExpirationTimeFromResponseBody(ResponseBody));
    end;

    /// <summary>   
    /// Deletes a message from a queue
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>
    /// <param name="MessageId">ID of the message to delete.</param>
    /// <param name="PopReceipt">PopReceipt of the message to delete.</param>
    /// <returns>TRUE if the message is deleted from the queue, FALSE otherwise.</returns> 
    procedure DeleteMessageFromQueue(StorageAccountName: Text; Queue: Text[20]; MessageID: Text[100]; PopReceipt: Text[30]): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.DeleteMessageFromQueue(StorageAccountName, Queue, MessageID, PopReceipt));
    end;

    /// <summary>   
    /// Deletes all messages from a queue
    /// </summary>    
    /// <param name="StorageAccountName">Name of the Azure Storage Account.</param>
    /// <param name="Queue">Name of the Azure queue.</param>    
    /// <returns>TRUE if the messages are cleared from the queue, FALSE otherwise.</returns> 
    procedure ClearMessagesFromQueue(StorageAccountName: Text; Queue: Text[20]): Boolean
    var
        AzureStorageQueueImpl: Codeunit "Azure Storage Queues Impl.";
    begin
        exit(AzureStorageQueueImpl.ClearMessagesFromQueue(StorageAccountName, Queue));
    end;






}