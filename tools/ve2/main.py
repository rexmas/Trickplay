import os
import signal

from PyQt4.QtGui import *
from PyQt4.QtCore import *
from UI.MainWindow import Ui_MainWindow
#from connection import *
from Inspector.TrickplayInspector import TrickplayInspector
from EmulatorManager.TrickplayEmulatorManager import TrickplayEmulatorManager

signal.signal(signal.SIGINT, signal.SIG_DFL)

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
        self.path = None
        QObject.connect(app, SIGNAL('aboutToQuit()'), self.exit)
        self.app = app
        self.command = None

    
    @property
    def emulatorManager(self):
        return self._emulatorManager
    
    @property
    def inspector(self):
        return self._inspector

    def openLua(self):
        inputCmd = str("_VE_.openLuaFile()")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = "openLuaFile"
        return True
    def open(self):
        inputCmd = str("_VE_.openFile()")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = "openFile"
        return True
    
    def newLayer(self):
        inputCmd = str("_VE_.newLayer()")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = "newLayer"
        return True

    def save(self):
        inputCmd = str("_VE_.saveFile()")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = "save"
        return True

    def textinput(self):
        inputCmd = str("_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'TextInput')")
        print inputCmd
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = "insertUIElement"
        return True

    def orbittingdots(self):
        inputCmd = str("_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'OrbittingDots')")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        self.command = "insertUIElement"
        return True

    def progressspinner(self):
        inputCmd = str("_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'ProgressSpinner')")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        return True

    def toastalert(self):
        inputCmd = str("_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'ToastAlert')")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        return True

    def dialogbox(self):
        inputCmd = str("_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'DialogBox')")
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        return True

    def button(self):
        inputCmd = str("_VE_.insertUIElement("+str(self._inspector.curLayerGid)+", 'Button')")
        print inputCmd 
        self._emulatorManager.trickplay.write(inputCmd+"\n")
        self._emulatorManager.trickplay.waitForBytesWritten()
        return True

    def stop(self, serverStoped=False, exit=False):
        # send 'q' command and close trickplay process
        self.onExit = exit

        if self._emulatorManager.trickplay.state() == QProcess.Running:
            # Local Debugging / Run 
            self._emulatorManager.trickplay.close()

    def run(self):
        self.inspector.clearTree()
        self._emulatorManager.run(False)

        self.ui.action_Run.setEnabled(False)
        self.ui.action_Stop.setEnabled(False)

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
