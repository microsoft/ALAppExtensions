// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoData.Warehousing;

using Microsoft.DemoTool.Helpers;

codeunit 5145 "Create Whse Item Category"
{
    InherentEntitlements = X;
    InherentPermissions = X;

    trigger OnRun()
    var
        ContosoItem: Codeunit "Contoso Item";
    begin
        ContosoItem.InsertItemCategory(Coffee(), CoffeeLbl, '');
        ContosoItem.InsertItemCategory(Beans(), BeansLbl, Coffee());
    end;

    var
        BeansTok: Label 'BEANS', MaxLength = 20;
        BeansLbl: Label 'Beans', MaxLength = 100;
        CoffeeTok: Label 'COFFEE', MaxLength = 20;
        CoffeeLbl: Label 'Coffee', MaxLength = 100;

    procedure Beans(): Code[20]
    begin
        exit(BeansTok);
    end;

    procedure Coffee(): Code[20]
    begin
        exit(CoffeeTok);
    end;
}
