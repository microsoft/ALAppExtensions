// ------------------------------------------------------------------------------------------------
// Copyright (c) Microsoft Corporation. All rights reserved.
// Licensed under the MIT License. See License.txt in the project root for license information.
// ------------------------------------------------------------------------------------------------
codeunit 135052 "Xml Validation Test Helper"
{
    Access = Internal;

    procedure GetXmlSchema() SchemaText: Text
    var
        StringBuilder: TextBuilder;
    begin
        StringBuilder.Append('<?xml version="1.0" encoding="utf-8"?>');
        StringBuilder.Append('<xs:schema attributeFormDefault="unqualified" elementFormDefault="qualified" targetNamespace="http://www.contoso.com/books" xmlns:xs="http://www.w3.org/2001/XMLSchema">');
        StringBuilder.Append('    <xs:element name="bookstore">');
        StringBuilder.Append('        <xs:complexType>');
        StringBuilder.Append('            <xs:sequence>');
        StringBuilder.Append('                <xs:element maxOccurs="unbounded" name="book">');
        StringBuilder.Append('                    <xs:complexType>');
        StringBuilder.Append('                        <xs:sequence>');
        StringBuilder.Append('                            <xs:element name="title" type="xs:string" />');
        StringBuilder.Append('                            <xs:element name="author">');
        StringBuilder.Append('                                <xs:complexType>');
        StringBuilder.Append('                                    <xs:sequence>');
        StringBuilder.Append('                                        <xs:element minOccurs="0" name="name" type="xs:string" />');
        StringBuilder.Append('                                        <xs:element minOccurs="0" name="first-name" type="xs:string" />');
        StringBuilder.Append('                                        <xs:element minOccurs="0" name="last-name" type="xs:string" />');
        StringBuilder.Append('                                    </xs:sequence>');
        StringBuilder.Append('                                </xs:complexType>');
        StringBuilder.Append('                            </xs:element>');
        StringBuilder.Append('                            <xs:element name="price" type="xs:decimal" />');
        StringBuilder.Append('                        </xs:sequence>');
        StringBuilder.Append('                        <xs:attribute name="genre" type="xs:string" use="required" />');
        StringBuilder.Append('                        <xs:attribute name="publicationdate" type="xs:date" use="required" />');
        StringBuilder.Append('                        <xs:attribute name="ISBN" type="xs:string" use="required" />');
        StringBuilder.Append('                    </xs:complexType>');
        StringBuilder.Append('                </xs:element>');
        StringBuilder.Append('            </xs:sequence>');
        StringBuilder.Append('        </xs:complexType>');
        StringBuilder.Append('    </xs:element>');
        StringBuilder.Append('</xs:schema>');

        SchemaText := StringBuilder.ToText();
    end;

    procedure GetNamespace(): Text
    begin
        exit('http://www.contoso.com/books');
    end;

    procedure GetValidXml() Xml: Text
    var
        StringBuilder: TextBuilder;
    begin
        StringBuilder.Append('<?xml version="1.0" encoding="utf-8" ?>');
        StringBuilder.Append('<bookstore xmlns="http://www.contoso.com/books">');
        StringBuilder.Append('    <book genre="autobiography" publicationdate="1981-03-22" ISBN="1-861003-11-0">');
        StringBuilder.Append('        <title>The Autobiography of Benjamin Franklin</title>');
        StringBuilder.Append('        <author>');
        StringBuilder.Append('            <first-name>Benjamin</first-name>');
        StringBuilder.Append('            <last-name>Franklin</last-name>');
        StringBuilder.Append('        </author>');
        StringBuilder.Append('        <price>8.99</price>');
        StringBuilder.Append('    </book>');
        StringBuilder.Append('    <book genre="novel" publicationdate="1967-11-17" ISBN="0-201-63361-2">');
        StringBuilder.Append('        <title>The Confidence Man</title>');
        StringBuilder.Append('        <author>');
        StringBuilder.Append('            <first-name>Herman</first-name>');
        StringBuilder.Append('            <last-name>Melville</last-name>');
        StringBuilder.Append('        </author>');
        StringBuilder.Append('        <price>11.99</price>');
        StringBuilder.Append('    </book>');
        StringBuilder.Append('    <book genre="philosophy" publicationdate="1991-02-15" ISBN="1-861001-57-6">');
        StringBuilder.Append('        <title>The Gorgias</title>');
        StringBuilder.Append('        <author>');
        StringBuilder.Append('            <name>Plato</name>');
        StringBuilder.Append('        </author>');
        StringBuilder.Append('        <price>9.99</price>');
        StringBuilder.Append('    </book>');
        StringBuilder.Append('</bookstore>');

        Xml := StringBuilder.ToText();
    end;

    /// <summary>
    /// Returns an invalid xml according to the schema
    /// </summary>
    procedure GetInvalidXml() Xml: Text
    var
        XmlDoc: XmlDocument;
        AnotherNode: XmlElement;
        RootElement: XmlElement;
    begin
        XmlDocument.ReadFrom(GetValidXml(), XmlDoc);
        AnotherNode := XmlElement.Create('anotherNode');
        XmlDoc.GetRoot(RootElement);
        RootElement.Add(AnotherNode);
        XmlDoc.WriteTo(Xml);
    end;
}