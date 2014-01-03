using System;
using System.Collections.Generic;
using System.Text;
using System.Xml;

namespace SDPlus {
	public class SDObjects {
		//--------------------------------------------------------------------
		/// <summary>
		/// ParseObjectXML -- process the XML description of an object
		/// </summary>
		/// <param name="objectNode"></param>
		/// <returns></returns>
		public static SortedList<string, string> ParseObjectXML(XmlNodeList objectNode) {
			SortedList<string, string> slv = new SortedList<string, string>();
			int i, j;

			slv.Clear();
			for (int n = 0; n < objectNode.Count; n++) {
				switch (objectNode[n].Name.ToLower()) {
					case "handle":
						slv.Add("Handle", objectNode[n].InnerText);
						break;
					case "attributes":
						XmlNodeList attributeNodeList = objectNode[n].ChildNodes;
						for (i = 0; i < attributeNodeList.Count; i++) {
							XmlNodeList items = attributeNodeList[i].ChildNodes;
							XmlAttributeCollection xAttr = attributeNodeList[i].Attributes;
							string dataType = xAttr["DataType"].Value;
							string attrName = "";
							string attrValue = "";
							for (j = 0; j < items.Count; j++) {
								switch (items[j].Name) {
									case "AttrName":
										attrName = items[j].InnerText;
										break;
									case "AttrValue":
										attrValue = items[j].InnerText;
										break;
									default:
										break;
								}
							}
							slv.Add(attrName, attrValue);
						}
						break;
					default:
						break;

				}
			}
			return slv;
		}
		//--------------------------------------------------------------------
		/// <summary>
		/// Return the attributes from an Object returned by doSelect
		/// </summary>
		/// <param name="objValues"></param>
		/// <param name="obj"></param>
		/// <returns></returns>
		public static SortedList<string, string> ParseObject(string objValues, int obj) {

			XmlDocument xDoc = new XmlDocument();
			xDoc.LoadXml(objValues);
			XmlNodeList udsObjects = xDoc.GetElementsByTagName("UDSObject");
			XmlNodeList objectNode = udsObjects[obj].ChildNodes;//xDoc.GetElementsByTagName("Attributes");
			return ParseObjectXML(objectNode);
		}
		//--------------------------------------------------------------------
		/// <summary>
		/// Return the attributes from an array of Objects returned by doSelect
		/// </summary>
		/// <param name="objValues"></param>
		/// <param name="obj"></param>
		/// <returns></returns>
		public static SortedList<string, string>[] ParseObjectArray(string objValues) {
			SortedList<string, string>[] slav;

			XmlDocument xDoc = new XmlDocument();
			xDoc.LoadXml(objValues);
			XmlNodeList udsObjects = xDoc.GetElementsByTagName("UDSObject");

			slav = new SortedList<string, string>[udsObjects.Count];

			for (int obj = 0; obj < udsObjects.Count; obj++) {
				XmlNodeList objectNode = udsObjects[obj].ChildNodes;//xDoc.GetElementsByTagName("Attributes");
				slav[obj] = ParseObjectXML(objectNode);
			}
			return slav;
		}
	}
}
