// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DemoTool;

using Microsoft.DemoData.Bank;
using Microsoft.DemoData.Common;
using Microsoft.DemoData.CRM;
using Microsoft.DemoData.eServices;
using Microsoft.DemoData.Finance;
using Microsoft.DemoData.FixedAsset;
using Microsoft.DemoData.Foundation;
using Microsoft.DemoData.HumanResources;
using Microsoft.DemoData.Inventory;
using Microsoft.DemoData.Jobs;
using Microsoft.DemoData.Manufacturing;
using Microsoft.DemoData.Purchases;
using Microsoft.DemoData.Sales;
using Microsoft.DemoData.Service;
using Microsoft.DemoData.Warehousing;

enum 5160 "Contoso Demo Data Module" implements "Contoso Demo Data Module"
{
    Extensible = true;

    value(0; "Common Module")
    {
        Implementation = "Contoso Demo Data Module" = "Common Module";
        Caption = 'Common';
    }
    value(1; "Manufacturing Module")
    {
        Implementation = "Contoso Demo Data Module" = "Manufacturing Module";
        Caption = 'Manufacturing';
    }
    value(2; "Warehouse Module")
    {
        Implementation = "Contoso Demo Data Module" = "Warehouse Module";
        Caption = 'Warehouse';
    }
    value(3; "Service Module")
    {
        Implementation = "Contoso Demo Data Module" = "Service Module";
        Caption = 'Service';
    }
    value(4; "Fixed Asset Module")
    {
        Implementation = "Contoso Demo Data Module" = "FA Module";
        Caption = 'Fixed Asset';
    }
    value(5; "Human Resources Module")
    {
        Implementation = "Contoso Demo Data Module" = "Human Resources Module";
        Caption = 'Human Resources';
    }
    value(6; "Job Module")
    {
        Implementation = "Contoso Demo Data Module" = "Job Module";
        Caption = 'Job';
    }
    value(10; Foundation)
    {
        Implementation = "Contoso Demo Data Module" = "Foundation Module";
        Caption = 'Foundation';
    }
    value(11; "Finance")
    {
        Implementation = "Contoso Demo Data Module" = "Finance Module";
        Caption = 'Finance';
    }
    value(12; CRM)
    {
        Implementation = "Contoso Demo Data Module" = "CRM Module";
        Caption = 'CRM';
    }
    value(13; "Bank")
    {
        Implementation = "Contoso Demo Data Module" = "Bank Module";
        Caption = 'Bank';
    }
    value(14; "Inventory")
    {
        Implementation = "Contoso Demo Data Module" = "Inventory Module";
        Caption = 'Inventory';
    }
    value(15; "Purchase")
    {
        Implementation = "Contoso Demo Data Module" = "Purchase Module";
        Caption = 'Purchase';
    }
    value(16; "Sales")
    {
        Implementation = "Contoso Demo Data Module" = "Sales Module";
        Caption = 'Sales';
    }
    value(17; EService)
    {
        Implementation = "Contoso Demo Data Module" = "EService Module";
        Caption = 'EService';
    }
}
