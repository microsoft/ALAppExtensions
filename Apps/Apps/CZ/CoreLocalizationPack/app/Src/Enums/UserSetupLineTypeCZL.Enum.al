// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
namespace System.Security.User;

enum 11725 "User Setup Line Type CZL"
{
    Extensible = true;

    value(0; "Location (quantity increase)")
    {
        Caption = 'Location (quantity increase)';
    }
    value(1; "Location (quantity decrease)")
    {
        Caption = 'Location (quantity decrease)';
    }
    value(2; "Bank Account")
    {
        Caption = 'Bank Account';
    }
    value(3; "General Journal")
    {
        Caption = 'General Journal';
    }
    value(4; "Item Journal")
    {
        Caption = 'Item Journal';
    }
#if not CLEAN26
    value(5; "BOM Journal")
    {
        Caption = 'BOM Journal (Obsolete)';
        ObsoleteState = Pending;
        ObsoleteReason = 'The BOM Journal is not used anymore.';
        ObsoleteTag = '26.0';
    }
#endif
    value(6; "Resource Journal")
    {
        Caption = 'Resource Journal';
    }
    value(7; "Job Journal")
    {
        Caption = 'Job Journal';
    }
#if not CLEAN26
    value(8; "Intrastat Journal")
    {
        Caption = 'Intrastat Journal (Obsolete)';
        ObsoleteState = Pending;
        ObsoleteReason = 'Intrastat related functionalities are moved to Intrastat extensions.';
        ObsoleteTag = '26.0';
    }
#endif
    value(9; "FA Journal")
    {
        Caption = 'FA Journal';
    }
    value(10; "Insurance Journal")
    {
        Caption = 'Insurance Journal';
    }
    value(11; "FA Reclass. Journal")
    {
        Caption = 'FA Reclass. Journal';
    }
    value(12; "Req. Worksheet")
    {
        Caption = 'Req. Worksheet';
    }
    value(13; "VAT Statement")
    {
        Caption = 'VAT Statement';
    }
    value(16; "Whse. Journal")
    {
        Caption = 'Whse. Journal';
    }
    value(17; "Whse. Worksheet")
    {
        Caption = 'Whse. Worksheet';
    }
    value(18; "Payment Order")
    {
        Caption = 'Payment Order';
    }
    value(19; "Bank Statement")
    {
        Caption = 'Bank Statement';
    }
    value(20; "Invt. Movement Templates")
    {
        Caption = 'Invt. Movement Templates';
    }
    value(21; "Release Location (quantity increase)")
    {
        Caption = 'Release Location (quantity increase)';
    }
    value(22; "Release Location (quantity decrease)")
    {
        Caption = 'Release Location (quantity decrease)';
    }
}
