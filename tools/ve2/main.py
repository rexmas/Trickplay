import os, signal,time, sys,threading
from PyQt4.QtGui import *
from PyQt4.QtCore import *

from wizard import Wizard
from UI.MainWindow import Ui_MainWindow
from UI.NewProjectDialog import Ui_newProjectDialog
from Inspector.TrickplayInspector import TrickplayInspector
from EmulatorManager.TrickplayEmulatorManager import TrickplayEmulatorManager

signal.signal(signal.SIGINT, signal.SIG_DFL)

"""
class MyThread (threading.Thread) :
	def __init__ (self, main=None) :
		self.main = main
		threading.Thread.__init__(self)
		self.stop_event = threading.Event()

	def stop(self):
		self.stop_event.set()

	def run (self):
		while not self.stop_event.isSet():
			#print "[VE] %s auto saved ... "%self.main.currentProject
            #TODO : backup current project 
			time.sleep(60)
"""

class MainWindow(QMainWindow):
    
    def __init__(self, app, apath=None, parent = None):
        
        QWidget.__init__(self, parent)
        
        self.apath = apath

        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)

        self.windows = {"inspector":False}
        self.inspectorWindowClicked()

        # Create Inspector
        self.ui.InspectorDock.toggleViewAction().setText("Inspector")
        self.ui.menuView.addAction(self.ui.InspectorDock.toggleViewAction())
        self.ui.InspectorDock.toggleViewAction().triggered.connect(self.inspectorWindowClicked)
        self._inspector = TrickplayInspector(self)
        self.ui.InspectorLayout.addWidget(self._inspector)
        
        # Create EmulatorManager
        self._emulatorManager = TrickplayEmulatorManager(self) 
        self._inspector.emulatorManager = self._emulatorManager

		#File Menu
        QObject.connect(self.ui.action_Exit, SIGNAL("triggered()"),  self.exit)
        QObject.connect(self.ui.actionLua_File_Engine_UI_Elements, SIGNAL("triggered()"),  self.openLua)
        QObject.connect(self.ui.actionJSON_New_UI_Elements, SIGNAL("triggered()"),  self.open)
        QObject.connect(self.ui.action_Save_2, SIGNAL("triggered()"),  self.save)
        QObject.connect(self.ui.actionNew_Layer, SIGNAL("triggered()"),  self.newLayer)
        QObject.connect(self.ui.actionNew_Project, SIGNAL("triggered()"),  self.newProject)
        QObject.connect(self.ui.actionOpen_Project, SIGNAL("triggered()"),  self.openProject)
        QObject.connect(self.ui.actionSave_Project, SIGNAL("triggered()"),  self.saveProject)
        
		#Edit Menu
        QObject.connect(self.ui.action_Button, SIGNAL("triggered()"),  self.button)
        QObject.connect(self.ui.actionDialog_Box, SIGNAL("triggered()"),  self.dialogbox)
        QObject.connect(self.ui.actionToastAlert, SIGNAL("triggered()"),  self.toastalert)
        QObject.connect(self.ui.actionProgressSpinner, SIGNAL("triggered()"),  self.progressspinner)
        QObject.connect(self.ui.actionOrbitting_Dots, SIGNAL("triggered()"),  self.orbittingdots)
        QObject.connect(self.ui.actionTextInput, SIGNAL("triggered()"),  self.textinput)

		#Run Menu
        QObject.connect(self.ui.action_Run, SIGNAL("triggered()"),  self.run)
        QObject.connect(self.ui.action_Stop, SIGNAL("triggered()"),  self.stop)
		
        # Restore sizes/positions of docks
        #self.restoreState(settings.value("mainWindowState").toByteArray());
        self.path =  None#os.path.join(self.apath, 'VE')
        self.app = app
        self.command = None
        self.currentProject = None

        #Start AutoSave Thread
        #self.autoSave = MyThread(self)
        #self.autoSave.start()
        QObject.connect(app, SIGNAL('aboutToQuit()'), self.exit)

    
    @property
    def emulatorManager(self):
        return self._emulatorManager
    
    @property
    def inspector(self):
        return self._inspector

    def sendLuaCommand(self, selfCmd, inputCmd):
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = selfCmd
        print inputCmd

    def openLua(self):
        self.sendLuaCommand("openLuaFile", "_VE_.openLuaFile()")
        return True

    def open(self):
        #self.sendLuaCommand("openFile", '_VE_.openFile("'+self.path+'")')
        self.sendLuaCommand("openFile", '_VE_.openFile("'+str(os.path.join(self.path, 'screens'))+'")')
        return True
    
    def setAppPath(self):
        #if self.path.startswith('/'):
            #self.path = self.path[1:]
        #self.sendLuaCommand("setAppPath", '_VE_.setAppPath("'+self.path+'")')
        self.sendLuaCommand("setAppPath", '_VE_.setAppPath("'+str(os.path.join(self.path, 'screens'))+'")')
        return True

    def newLayer(self):
        self.sendLuaCommand("newLayer", "_VE_.newLayer()")
        return True

    def newProject(self):
        orgPath = self.path
        wizard = Wizard(self)
        path = wizard.start("", False, True)
        if path is not None:
            #print "NEW PATH : %s"%path
            if path and path != orgPath :
                settings = QSettings()
                if settings.value('path') is not None:
                    settings.setValue('path', path)
                    pass
            
            self.start(path)
            self.setAppPath()
            self.run()
            self.command = "newProject"
            self.inspector.screens = {"_AllScreens":[],"Default":[]}
            return True

    def openProject(self):
        print("openProject")
        wizard = Wizard()
        path = -1
        while path == -1 :
            if self.path is None:
		        self.path = self.apath
            path = QFileDialog.getExistingDirectory(None, 'Open Project', self.path, QFileDialog.ShowDirsOnly)
            path = wizard.start(path, True)
        print ("[VDBG] Open Project [%s]"%path)
        if path:
            settings = QSettings()
            if settings.value('path') is not None:
                self.stop()
            settings.setValue('path', path)
            self.start(str(path))
            self.setAppPath()
            self.run()
            self.command = "openProject"
            self.inspector.screens = {"_AllScreens":[],"Default":[]}
        return True

    def saveProject(self):
        print("saveProject")
        self.sendLuaCommand("saveProject", "_VE_.saveProject()")
        return True

    def save(self):
        self.setAppPath()
        self.sendLuaCommand("save", "_VE_.saveFile(\'"+self.inspector.screen_json()+"\')")
        print("_VE_.saveFile(\'"+self.inspector.screen_json()+"\')")
        return True

    def textinput(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'TextInput')")
        return True

    def orbittingdots(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'OrbittingDots')")
        return True

    def progressspinner(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'ProgressSpinner')")
        return True

    def toastalert(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'ToastAlert')")
        return True

    def dialogbox(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'DialogBox')")
        return True

    def button(self):
        self.sendLuaCommand("insertUIElement", "_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'Button')")
        return True

    def stop(self, serverStoped=False, exit=False):
        # send 'q' command and close trickplay process
        self.onExit = exit

        if self._emulatorManager.trickplay.state() == QProcess.Running:
            # Local Debugging / Run 
            self._emulatorManager.trickplay.close()

    def run(self):
        self.inspector.clearTree()
        self._emulatorManager.run()

        #self.ui.action_Run.setEnabled(False)
        #self.ui.action_Stop.setEnabled(False)

    def exit(self):
        self.stop(False, True)
        #self._emulatorManager.stop()
        self.close()

    def inspectorWindowClicked(self) :
    	if self.windows['inspector'] == True:
    		self.ui.InspectorDock.hide()
    		self.windows['inspector'] = False
    	else :
    		self.ui.InspectorDock.show()
    		self.windows['inspector'] = True

    def start(self, path, openList = None):
        """
        Initialize widgets on the main window with a given app path
        """
        self.path = path
        #self._emulatorManager.setPath(path)
        if path is not -1:
            self.setWindowTitle(QApplication.translate("MainWindow", "TrickPlay VE2 [ "+str(os.path.basename(str(path))+" ]"), None, QApplication.UnicodeUTF8))
            self.currentProject = str(os.path.basename(str(path)))
