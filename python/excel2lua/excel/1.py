# -*- coding: utf-8 -*-

path = "E:/learningStuff/pythonMakelua/excel/"
import sys
import xlrd

reload(sys)
sys.setdefaultencoding('utf-8')

def open_excel(file = "E:/learningStuff/pythonMakelua/excel/file.xlsx"):
    try:
        data = xlrd.open_workbook(filename=file,encoding_override="utf-8")
        return data
    except Exception,e:
       print str(e)

#@param fileName:输出文件名称
#@param SheetName:excel表名
#@param textList:字段是text
#@param floatList:字段是float
#@param colNameIndex:属性字段行
#@param index:真实数据开始行，跳过注释行
#@param colnames:属性字段表
#@param spaceIndex:那个字段为空的话，则判定该行是空行
def excel_table_byname(fileName="fileName",SheetName="Catalog",textList = [],floatList = [],colNameIndex = 0,index=0,file="E:/learningStuff/pythonMakelua/excel/file.xlsx",colnames=[],spaceIndex=0):
    data = open_excel(file)
    table = data.sheet_by_name(SheetName)
    nrows = table.nrows #行数 

    if len(colnames) == 0:
        colnames = table.row_values(colNameIndex);

    list = []
    file = open(path + "gen/"+fileName+".lua","w");
    file.write(fileName);
    file.write(" = ");
    file.write("{\n");

    for rownum in range(index,nrows):
         row = table.row_values(rownum)
         if row and row[spaceIndex]!="" and isinstance(row[spaceIndex],float):
             app = {}
             file.write("{");
             for i in range(len(colnames)):
                if colnames[i] == "":
                  continue;
                  pass
                file.write(colnames[i]);
                file.write(" = ");
                find = False;

                # text
                for x in textList:
                  if colnames[i] == x:
                    find = True;
                    file.write("\"");
                    tmp = str(row[i]);
                    if tmp == "0" or tmp == "0.0":
                      file.write("");
                    else:
                      file.write(tmp);
                    file.write("\"");
                  pass

                # float
                for x in floatList:
                  if colnames[i] == x:
                    find = True;
                    if row[i]!="" and str(row[i]).strip():
                      file.write(str(float(row[i])));
                    else:
                      file.write("0.0");
                  pass

                if find == False:
                    tmp = str(row[i]);
                    if tmp.upper() == "TRUE":
                      file.write("true");
                    elif tmp.upper() == "FALSE":
                      file.write("false");
                    elif tmp!="" and tmp.strip():
                      file.write(str(int(row[i])));
                    else:
                      file.write("0");

                if i < len(colnames)-1:
                  file.write(",");
                pass

                app[colnames[i]] = row[i]

             list.append(app)
             file.write("}");
             if rownum < nrows-1:
              file.write(",");

             
             file.write("\n");

    file.write("};");  
    file.close();       
    return list

def main():
   tables = excel_table_byname(SheetName="Catalog",textList=["SheetName","FileName", "Server", "Client"],index=4,colnames=["id","SheetName","FileName", "Server", "Client"])
   for row in tables:
    if row["SheetName"] == "任务模板表":
      print(row["SheetName"]+":开始导出....")
      text_ = ["task_title","details","details_objective","front_task","follow_task"];
      tables = excel_table_byname(SheetName=row["SheetName"],fileName=row["FileName"],textList=text_,index=2,colNameIndex=0,spaceIndex=0);
      print(row["SheetName"]+":导出结束....\n")

    elif row["SheetName"] == "任务条件表":
      print(row["SheetName"]+":开始导出....")
      text_ = ["task_target"];
      tables = excel_table_byname(SheetName=row["SheetName"],fileName=row["FileName"],textList=text_,index=2,colNameIndex=0,spaceIndex=0);
      print(row["SheetName"]+":导出结束....\n")

    elif row["SheetName"] == "物品掉落表":
      print(row["SheetName"]+":开始导出....")
      text_ = ["level_name","drop_1","fixdrop_1","drop_2","fixdrop_2","drop_3","fixdrop_3","drop_4","fixdrop_4","drop_5","fixdrop_5","drop_6","fixdrop_6","drop_7","fixdrop_7","drop_8","fixdrop_8","drop_9","fixdrop_9","drop_10","fixdrop_10"];
      tables = excel_table_byname(SheetName=row["SheetName"],fileName=row["FileName"],textList=text_,index=2,colNameIndex=0,spaceIndex=0);
      print(row["SheetName"]+":导出结束....\n")

    elif row["SheetName"] == "炸弹数据表":
      print(row["SheetName"]+":开始导出....")
      text_ = ["name","launch_voice","explode_voice","offsetRight","offsetLeft"];
      float_ = ["hurt"];
      tables = excel_table_byname(SheetName=row["SheetName"],floatList=float_,fileName=row["FileName"],textList=text_,index=2,colNameIndex=0,spaceIndex=0);
      print(row["SheetName"]+":导出结束....\n")
    # print(row);

if __name__=="__main__":

    main()



