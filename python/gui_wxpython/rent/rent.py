# -*- coding: utf-8 -*-
# Description:  test
# Author：yzj 2015.11.20

import urllib
import sys
import os
# import os.path
# import xlrd
# import fileinput
import re

USE_GENERIC = 0

import wx
import wx.lib.mixins.inspection
if USE_GENERIC:
    from wx.lib.stattext import GenStaticText as StaticText
else:
    StaticText = wx.StaticText

reload(sys)
sys.setdefaultencoding('utf-8')

class MyPanel(wx.Panel):
    def __init__(self, parent):
        wx.Panel.__init__(self, parent, size=(1,1))

        # self.SetBackgroundColour("Gray")
        # self.SetBackgroundColour("sky blue")
        StaticText(self, -1, "中文标签控件".decode('utf-8').encode('gb2312'), (120, 70)) #.SetBackgroundColour('Orange')
        StaticText(self, -1, "this is a label in English\nthis is a label in English12", (120, 100))
        os.system('ls')

        #os system
        self.cmdLabel = wx.TextCtrl(self, -1, "echo 'please input os cmd'", (0, 0),(560,-1))
        self.cmdBtn = wx.Button(self, -1, "Execute", (0, 30), (60, 30))
        self.Bind(wx.EVT_BUTTON, self.onCmdBtn, self.cmdBtn)

    def onCmdBtn(self, evt):
        cmd = self.cmdLabel.GetValue()
        print cmd
        os.system(cmd)
        #self.tc.Remove(5, 9)


class wxPythonDemo(wx.Frame):

    overviewText = "wxPython Demo"

    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, -1, title, size = (640,480),
                          style=wx.DEFAULT_FRAME_STYLE | wx.NO_FULL_REPAINT_ON_RESIZE)
        self.SetMinSize((640,480))
        self.Bind(wx.EVT_CLOSE, self.OnCloseWindow)

        self.panel = panel = MyPanel(self)



    def OnCloseWindow(self, event):
        self.Destroy()



class MyApp(wx.App, wx.lib.mixins.inspection.InspectionMixin):
    def OnInit(self):
        frame = wxPythonDemo(None, "Renting System")
        frame.Show()
        return True

def main():
    try:
        demoPath = os.path.dirname(__file__)
        os.chdir(demoPath)
    except:
        pass
    app = MyApp(False)
    app.MainLoop()


if __name__=="__main__":
    __name__ = 'Main'
    main()



