// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace Microsoft.Finance.TaxEngine;

using Microsoft.Finance.TaxEngine.Core;
using Microsoft.Finance.TaxEngine.JsonExchange;
using Microsoft.Finance.TaxEngine.PostingHandler;
using Microsoft.Finance.TaxEngine.ScriptHandler;
using Microsoft.Finance.TaxEngine.TaxTypeHandler;
using Microsoft.Finance.TaxEngine.UseCaseBuilder;

permissionset 20138 "D365 Access - IN Tax Engine"
{
    Access = Internal;
    Assignable = false;
    Caption = 'D365 Access - IN Tax Engine';

    IncludedPermissionSets = "Adv Objects - Tax Engine";

    Permissions = tabledata "Tax Engine Notification" = RMID,
                  tabledata "Upgraded Tax Types" = RMID,
                  tabledata "Upgraded Use Cases" = RMID,
                  tabledata "Action Comment" = RIMD,
                  tabledata "Action Concatenate" = RIMD,
                  tabledata "Action Concatenate Line" = RIMD,
                  tabledata "Action Container" = RIMD,
                  tabledata "Action Convert Case" = RIMD,
                  tabledata "Action Date Calculation" = RIMD,
                  tabledata "Action Date To DateTime" = RIMD,
                  tabledata "Action Ext. Substr. From Index" = RIMD,
                  tabledata "Action Ext. Substr. From Pos." = RIMD,
                  tabledata "Action Extract Date Part" = RIMD,
                  tabledata "Action Extract DateTime Part" = RIMD,
                  tabledata "Action Find Date Interval" = RIMD,
                  tabledata "Action Find Substring" = RIMD,
                  tabledata "Action If Statement" = RIMD,
                  tabledata "Action Length Of String" = RIMD,
                  tabledata "Action Loop N Times" = RIMD,
                  tabledata "Action Loop Through Rec. Field" = RIMD,
                  tabledata "Action Loop Through Records" = RIMD,
                  tabledata "Action Loop With Condition" = RIMD,
                  tabledata "Action Message" = RIMD,
                  tabledata "Action Number Calculation" = RIMD,
                  tabledata "Action Number Expr. Token" = RIMD,
                  tabledata "Action Number Expression" = RIMD,
                  tabledata "Action Replace Substring" = RIMD,
                  tabledata "Action Round Number" = RIMD,
                  tabledata "Action Set Variable" = RIMD,
                  tabledata "Action String Expr. Token" = RIMD,
                  tabledata "Action String Expression" = RIMD,
                  tabledata "Entity Attribute Mapping" = RIMD,
                  tabledata "Lookup Field Filter" = RIMD,
                  tabledata "Lookup Field Sorting" = RIMD,
                  tabledata "Lookup Table Filter" = RIMD,
                  tabledata "Lookup Table Sorting" = RIMD,
                  tabledata "Record Attribute Mapping" = RIMD,
                  tabledata "Script Action" = RIMD,
                  tabledata "Script Context" = RIMD,
                  tabledata "Script Editor Line" = RIMD,
                  tabledata "Script Record Variable" = RIMD,
                  tabledata "Script Symbol" = RIMD,
                  tabledata "Script Symbol Lookup" = RIMD,
                  tabledata "Script Symbol Member Value" = RIMD,
                  tabledata "Script Symbol Value" = RIMD,
                  tabledata "Script Variable" = RIMD,
                  tabledata "Switch Case" = RIMD,
                  tabledata "Switch Statement" = RIMD,
                  tabledata "Tax Acc. Period Setup" = RIMD,
                  tabledata "Tax Attribute" = RIMD,
                  tabledata "Tax Attribute Value" = RIMD,
                  tabledata "Tax Attribute Value Mapping" = RIMD,
                  tabledata "Tax Component" = RIMD,
                  tabledata "Tax Component Expr. Token" = RIMD,
                  tabledata "Tax Component Expression" = RIMD,
                  tabledata "Tax Component Formula" = RIMD,
                  tabledata "Tax Component Formula Token" = RIMD,
                  tabledata "Tax Component Summary" = RIMD,
                  tabledata "Tax Entity" = RIMD,
                  tabledata "Tax Insert Record" = RIMD,
                  tabledata "Tax Insert Record Field" = RIMD,
                  tabledata "Tax Posting Keys Buffer" = RIMD,
                  tabledata "Tax Posting Setup" = RIMD,
                  tabledata "Tax Rate" = RIMD,
                  tabledata "Tax Rate Column Setup" = RIMD,
                  tabledata "Tax Rate Value" = RIMD,
                  tabledata "Tax Rate Filter" = RIMD,
                  tabledata "Tax Table Relation" = RIMD,
                  tabledata "Tax Test Condition" = RIMD,
                  tabledata "Tax Test Condition Item" = RIMD,
                  tabledata "Tax Transaction Value" = RIMD,
                  tabledata "Tax Type" = RIMD,
                  tabledata "Tax Use Case" = RIMD,
                  tabledata "Transaction Posting Buffer" = RIMD,
                  tabledata "Use Case Archival Log Entry" = RIMD,
                  tabledata "Tax Type Archival Log Entry" = RIMD,
                  tabledata "Use Case Attribute Mapping" = RIMD,
                  tabledata "Use Case Component Calculation" = RIMD,
                  tabledata "Use Case Rate Column Relation" = RIMD,
                  tabledata "Use Case Tree Node" = RIMD;
}
