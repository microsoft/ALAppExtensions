// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

/// <summary>
/// The Record Reference interface provides a method for delegating read/write operations for tables that require indirect permissions.
/// </summary>
interface "Record Reference"
{
    Access = Public;

    /// <summary>
    /// Determines if you can read from a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>true if you can read from some or all of the table; otherwise, false.</returns>
    procedure ReadPermission(RecordRef: RecordRef): Boolean

    /// <summary>
    /// Determines if you can write to a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>Specifies if you have permission to write to the table</returns>
    procedure WritePermission(RecordRef: RecordRef): Boolean

    /// <summary>
    /// Counts the number of records that are in the filters that are currently applied to the table referred to by the RecordRef.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>The number of records in the table.</returns>
    procedure Count(RecordRef: RecordRef): Integer

    /// <summary>
    /// Gets an approximate count of the number of records in the table
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>Approximate number of records in the table.</returns>
    procedure CountApprox(RecordRef: RecordRef): Integer

    /// <summary>
    /// Determines whether any records exist in a filtered set of records in a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>true if the record or table is empty; otherwise, false.</returns>
    procedure IsEmpty(RecordRef: RecordRef): Boolean

    /// <summary>
    /// Finds a record in a table based on the values stored in the key fields.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="Which">Specifies how to perform the search.</param>
    procedure Find(RecordRef: RecordRef; Which: Text)

    /// <summary>
    /// Finds a record in a table based on the values stored in the key fields.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="Which">Specifies how to perform the search.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure Find(RecordRef: RecordRef; Which: Text; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Finds the last record in a table based on the current key and filter.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    procedure FindLast(RecordRef: RecordRef)

    /// <summary>
    /// Finds the last record in a table based on the current key and filter.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure FindLast(RecordRef: RecordRef; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Finds the first record in a table based on the current key and filter.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure FindFirst(RecordRef: RecordRef)

    /// <summary>
    /// Finds the first record in a table based on the current key and filter.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure FindFirst(RecordRef: RecordRef; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Finds a set of records in a table based on the current key and filter. FINDSET can only retrieve records in ascending order.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    procedure FindSet(RecordRef: RecordRef)

    /// <summary>
    /// Finds a set of records in a table based on the current key and filter. FINDSET can only retrieve records in ascending order.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure FindSet(RecordRef: RecordRef; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Finds a set of records in a table based on the current key and filter. FINDSET can only retrieve records in ascending order.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="ForUpdate">Set this parameter to false if you do not want to modify any records in the set.</param>
    /// <param name="UpdateKey">This parameter only applies if ForUpdate is true. If you are going to modify any field value within the current key, set this parameter to true.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure FindSet(RecordRef: RecordRef; ForUpdate: Boolean; UpdateKey: Boolean; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Steps through a specified number of records and retrieves a record.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="Steps">Defines the direction of the search and how many records to step include.</param>
    /// <returns>the direction of the search and how many steps taken.</returns>
    procedure Next(RecordRef: RecordRef; Steps: Integer): Integer

    /// <summary>
    /// Steps through a specified number of records and retrieves a record.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <returns>the direction of the search and how many steps taken.</returns>
    procedure Next(RecordRef: RecordRef): Integer

    /// <summary>
    /// Gets a record based on the ID of the record.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RecordId">The RecordID that contains the table number and the primary key of the table and is used to identify the record that you want to get.</param>
    procedure Get(RecordRef: RecordRef; RecordId: RecordId)

    /// <summary>
    /// Gets a record based on the ID of the record.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RecordId">The RecordID that contains the table number and the primary key of the table and is used to identify the record that you want to get.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure Get(RecordRef: RecordRef; RecordId: RecordId; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Gets a record based on the ID of the record. The RecordRef must already be opened.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="SystemId">The systemid which uniquely identifies the record that you want to get.</param>
    procedure GetBySystemId(RecordRef: RecordRef; SystemId: Guid)

    /// <summary>
    /// Gets a record based on the ID of the record. The RecordRef must already be opened.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="SystemId">The systemid which uniquely identifies the record that you want to get.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure GetBySystemId(RecordRef: RecordRef; SystemId: Guid; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Inserts a record into a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">If this parameter is true, the code in the OnInsert Trigger is executed.</param>
    procedure Insert(RecordRef: RecordRef; RunTrigger: Boolean)

    /// <summary>
    /// Inserts a record into a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">If this parameter is true, the code in the OnInsert Trigger is executed.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure Insert(RecordRef: RecordRef; RunTrigger: Boolean; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Inserts a record into a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">If this parameter is true, the code in the OnInsert Trigger is executed.</param>
    /// <param name="InsertWithSystemId">If this parameter is true, the SystemId field of the record is given a value that you explicitly assign.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure Insert(RecordRef: RecordRef; RunTrigger: Boolean; InsertWithSystemId: Boolean; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Modifies a record in a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">Specifies whether to run the AL code in the OnModify Trigger.</param>
    procedure Modify(RecordRef: RecordRef; RunTrigger: Boolean)

    /// <summary>
    /// Modifies a record in a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">Specifies whether to run the AL code in the OnModify Trigger.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure Modify(RecordRef: RecordRef; RunTrigger: Boolean; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Deletes a record in a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">Specifies whether the code in the OnDelete trigger will be executed.</param>
    procedure Delete(RecordRef: RecordRef; RunTrigger: Boolean)

    /// <summary>
    /// Deletes a record in a table.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">Specifies whether the code in the OnDelete trigger will be executed.</param>
    /// <param name="UseReturnValue">If you set UseReturnValue to false and the operation does not execute successfully, a runtime error will occur.</param>
    /// <returns>true if the operation was successful; otherwise false. </returns>
    procedure Delete(RecordRef: RecordRef; RunTrigger: Boolean; UseReturnValue: Boolean): Boolean

    /// <summary>
    /// Deletes all records in a table that fall within a specified range.
    /// </summary>
    /// <param name="RecordRef">An instance of the RecordRef data type.</param>
    /// <param name="RunTrigger">Specifies whether the code in the OnDelete trigger will be executed.</param>
    procedure DeleteAll(RecordRef: RecordRef; RunTrigger: Boolean)
}