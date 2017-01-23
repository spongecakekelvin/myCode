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
USE_CUSTOMTREECTRL = False

import wx
import wx.lib.mixins.inspection
if USE_GENERIC:
    from wx.lib.stattext import GenStaticText as StaticText
else:
    StaticText = wx.StaticText

reload(sys)
sys.setdefaultencoding('utf-8')

_treeList = [
    ('excel2lua',[]),
    ('More',[]),
    
]

class MainPanel(wx.Panel):
    def __init__(self, parent):
        wx.Panel.__init__(self, parent, size=(1,1))

    #     # self.SetBackgroundColour("Gray")
    #     # self.SetBackgroundColour("sky blue")
    #     StaticText(self, -1, "中文标签控件".decode('utf-8').encode('gb2312'), (120, 70)) #.SetBackgroundColour('Orange')
    #     StaticText(self, -1, "this is a label in English\nthis is a label in English12", (120, 100))

    #     #os system
    #     self.cmdLabel = wx.TextCtrl(self, -1, "echo 'please input os cmd'", (0, 0),(560,-1))
    #     self.cmdBtn = wx.Button(self, -1, "Execute", (0, 30), (60, 30))
    #     self.Bind(wx.EVT_BUTTON, self.onCmdBtn, self.cmdBtn)

    def onCmdBtn(self, evt):
        cmd = self.cmdLabel.GetValue()
        print cmd
        os.system(cmd)
        #self.tc.Remove(5, 9)

#---------------------------------------------------------------------------

from wx.lib.mixins.treemixin import ExpansionState
if USE_CUSTOMTREECTRL:
    import wx.lib.customtreectrl as CT
    TreeBaseClass = CT.CustomTreeCtrl
else:
    TreeBaseClass = wx.TreeCtrl

class wxPythonDemoTree(ExpansionState, TreeBaseClass):
    def __init__(self, parent):
        TreeBaseClass.__init__(self, parent, style=wx.TR_DEFAULT_STYLE|
                               wx.TR_HAS_VARIABLE_ROW_HEIGHT)
        if USE_CUSTOMTREECTRL:
            self.SetSpacing(10)
            self.SetWindowStyle(self.GetWindowStyle() & ~wx.TR_LINES_AT_ROOT)

        self.SetInitialSize((100,80))

    def AppendItem(self, parent, text, image=-1, wnd=None):
        if USE_CUSTOMTREECTRL:
            item = TreeBaseClass.AppendItem(self, parent, text, image=image, wnd=wnd)
        else:
            item = TreeBaseClass.AppendItem(self, parent, text, image=image)
        return item
            
    def GetItemIdentity(self, item):
        return self.GetPyData(item)

#---------------------------------------------------------------------------
        

class wxPythonDemo(wx.Frame):

    overviewText = "wxPython Demo"
 
    def __init__(self, parent, title):
        wx.Frame.__init__(self, parent, -1, title, size = (640,480),
                          style=wx.DEFAULT_FRAME_STYLE | wx.NO_FULL_REPAINT_ON_RESIZE)
        self.SetMinSize((640,480))
        self.Bind(wx.EVT_CLOSE, self.OnCloseWindow)
        
        self.dying = False
        self.skipLoad = False
        self.allowAuiFloating = False
        self.loaded = True

        self.ReadConfigurationFile()
        leftPanel = self.pnl = pnl = MainPanel(self)

        # Create a TreeCtrl
        # leftPanel = wx.Panel(pnl, style=wx.TAB_TRAVERSAL|wx.CLIP_CHILDREN)
        
        # self.tree = wx.TreeCtrl(leftPanel, 1, wx.DefaultPosition, (-1, -1),   
        #                         wx.TR_HAS_BUTTONS|wx.TR_HAS_VARIABLE_ROW_HEIGHT)  
        # root = self.tree.AddRoot('1')  
        # os = self.tree.AppendItem(root, '2')  
        # pl = self.tree.AppendItem(root, '3')  
        # tk = self.tree.AppendItem(root, '4')  

        self.tree = wxPythonDemoTree(leftPanel)
        self.RecreateTree()
        self.expansionState = [0, 1]
        self.tree.SetExpansionState(self.expansionState)
        self.tree.Bind(wx.EVT_TREE_ITEM_EXPANDED, self.OnItemExpanded)
        self.tree.Bind(wx.EVT_TREE_ITEM_COLLAPSED, self.OnItemCollapsed)
        self.tree.Bind(wx.EVT_TREE_SEL_CHANGED, self.OnSelChanged)
        self.tree.Bind(wx.EVT_LEFT_DOWN, self.OnTreeLeftDown)

        self.filter = wx.SearchCtrl(leftPanel, style=wx.TE_PROCESS_ENTER)
        self.filter.ShowCancelButton(True)

        leftBox = wx.BoxSizer(wx.VERTICAL)
        leftBox.Add(self.tree, 1, wx.EXPAND)
        leftBox.Add(wx.StaticText(leftPanel, label = "Filter Demos:"), 0, wx.TOP|wx.LEFT, 5)
        leftBox.Add(self.filter, 0, wx.EXPAND|wx.ALL, 5)
        if 'wxMac' in wx.PlatformInfo:
            leftBox.Add((5,5))  # Make sure there is room for the focus ring
        leftPanel.SetSizer(leftBox)

    def ReadConfigurationFile(self):
        self.expansionState = [0, 1]

    def RecreateTree(self, evt=None):
        self.root = self.tree.AddRoot("wxPython Overview")
        self.tree.SetItemImage(self.root, 0)
        self.tree.SetItemPyData(self.root, 0)

        for category, items in _treeList:
            child = self.tree.AppendItem(self.root, category)

        self.tree.Expand(self.root)

    #---------------------------------------------
    def OnItemExpanded(self, event):
        item = event.GetItem()
        # wx.LogMessage("OnItemExpanded: %s" % self.tree.GetItemText(item))
        event.Skip()

    #---------------------------------------------
    def OnItemCollapsed(self, event):
        item = event.GetItem()
        # wx.LogMessage("OnItemCollapsed: %s" % self.tree.GetItemText(item))
        event.Skip()

    #---------------------------------------------
    def OnTreeLeftDown(self, event):
        # reset the overview text if the tree item is clicked on again
        pt = event.GetPosition();
        item, flags = self.tree.HitTest(pt)
        if item == self.tree.GetSelection():
            # print self.tree.GetItemText(item)
            pass
        #     self.SetOverview(self.tree.GetItemText(item)+" Overview", self.curOverview)
        event.Skip()

    #---------------------------------------------
    def OnSelChanged(self, event):
        if self.dying or not self.loaded or self.skipLoad:
            return

        item = event.GetItem()
        itemText = self.tree.GetItemText(item)
        print itemText
        # self.LoadDemo(itemText)
    
    #---------------------------------------------
    def SetOverview(self, name, text):
        self.curOverview = text
        lead = text[:6]
        if lead != '<html>' and lead != '<HTML>':
            text = '<br>'.join(text.split('\n'))
        if wx.USE_UNICODE:
            text = text.decode('iso8859_1')  
        self.ovr.SetPage(text)
        self.nb.SetPageText(0, os.path.split(name)[1])

    #--------------------------------------------- 
    def OnCloseWindow(self, event):
        self.dying = True
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



