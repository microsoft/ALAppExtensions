namespace Microsoft.Integration.Shopify;

/// <summary>
/// Enum Shpfy Metafield Type (ID 30159).
/// </summary>
enum 30159 "Shpfy Metafield Type" implements "Shpfy IMetafield Type"
{
    Access = Internal;
    Caption = 'Shopify  Metafield Type';

    Extensible = false;

    value(0; string)
    {
        Caption = 'String';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type String";
    }

    value(1; integer)
    {
        Caption = 'Integer';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Integer";
    }

    value(2; json)
    {
        Caption = 'JSON';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type JSON";
    }

    value(3; boolean)
    {
        Caption = 'True or false';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Boolean";
    }

    value(4; color)
    {
        Caption = 'Color';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Color";
    }

    value(5; date)
    {
        Caption = 'Date';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Date";
    }

    value(6; date_time)
    {
        Caption = 'Date and time';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type DateTime";
    }

    value(7; dimension)
    {
        Caption = 'Dimension';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Dimension";
    }

    value(8; money)
    {
        Caption = 'Money';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Money";
    }

    value(9; multi_line_text_field)
    {
        Caption = 'Multi-line text';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Multi Text";
    }

    value(10; number_decimal)
    {
        Caption = 'Decimal';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Num Decimal";
    }

    value(11; number_integer)
    {
        Caption = 'Integer';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Num Integer";
    }

    // Intentionally commented out as we are not supporting this type at the moment
    // value(12; rating)
    // {
    //     Caption = 'Rating';
    // }

    // Intentionally commented out as we are not supporting this type at the moment
    // value(13; rich_text_field)
    // {
    //     Caption = 'Rich text';
    // }

    value(14; single_line_text_field)
    {
        Caption = 'Single line text';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Single Text";
    }

    value(15; url)
    {
        Caption = 'URL';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type URL";
    }

    value(16; volume)
    {
        Caption = 'Volume';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Volume";
    }

    value(17; weight)
    {
        Caption = 'Weight';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Weight";
    }
    value(18; collection_reference)
    {
        Caption = 'Collection reference';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Collect. Ref";
    }

    value(19; file_reference)
    {
        Caption = 'File';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type File Ref";
    }

    value(20; metaobject_reference)
    {
        Caption = 'Metaobject';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Metaobj. Ref";
    }

    value(21; mixed_reference)
    {
        Caption = 'Mixed reference';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Mixed Ref";
    }

    value(22; page_reference)
    {
        Caption = 'Page';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Page Ref";
    }

    value(23; product_reference)
    {
        Caption = 'Product';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Product Ref";
    }

    value(24; variant_reference)
    {
        Caption = 'Variant';
        Implementation = "Shpfy IMetafield Type" = "Shpfy Mtfld Type Variant Ref";
    }
}