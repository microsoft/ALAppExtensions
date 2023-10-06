// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved. 
// Licensed under the MIT License. See License.txt in the project root for license information. 
// ------------------------------------------------------------------------------------------------

namespace Microsoft.DataMigration.C5;

table 1888 "C5 InvenPrice"
{
    ReplicateData = false;

    fields
    {
        field(1; RecId; Integer)
        {
            Caption = 'Row number';
        }
        field(2; LastChanged; Date)
        {
            Caption = 'Last changed';
        }
        field(3; ItemNumber; Code[20])
        {
            Caption = 'Item number';
        }
        field(4; Price; Decimal)
        {
            Caption = 'Price';
        }
        field(5; PriceUnit; Decimal)
        {
            Caption = 'Unit';
        }
        field(6; Currency; Code[3])
        {
            Caption = 'Currency';
        }
        field(7; PriceGroup; Code[10])
        {
            Caption = 'Price group';
        }
        field(8; ContributionRatio; Decimal)
        {
            Caption = 'Contrib. ratio';
        }
        field(9; Date_; Date)
        {
            Caption = 'Date';
        }
        field(10; SalesVat; Code[10])
        {
            Caption = 'Sales VAT';
        }
    }

    keys
    {
        key(PK; RecId)
        {
            Clustered = true;
        }
    }
}

