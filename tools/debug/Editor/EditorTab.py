
from PyQt4.QtGui import *
from PyQt4.QtCore import *

from Editor import Editor


class EditorTabWidget(QTabWidget):

    def __init__(self, main, windowsMenu=None, fileSystem = None, parent = None, m=None):
        
        QTabWidget.__init__(self, parent)
        
        self.setDocumentMode(True)
        self.setTabsClosable(True)
        self.setMovable(True)
        self.setCurrentIndex(-1)
        self.setAcceptDrops(True)
        
        self.m = m
        self.main = main
        self.paths = []
        self.editors = []
        self.textBefores = []
        self.windowsMenu = windowsMenu
        self.fileSystem = fileSystem
        self.tabClosing = False 
        
        QObject.connect(self, SIGNAL('tabCloseRequested(int)'), self.closeTab)
        QObject.connect(self, SIGNAL('currentChanged(int)'), self.changeTab)
        
    def dragEnterEvent(self, event):
        event.acceptProposedAction()
        
    def dropEvent(self, event):
        self.main.dropFileEvent(event, 'tab', self)
        
    def closeTab(self, index):
		if index < 0:
			return 
		# find current index tab 
		#index = self.currentIndex()

		editor = self.editors[index] #self.app.focusWidget()
		
		# reset the windowsActions'shortcuts 
		n=0
		for edt in self.editors:
			if n > index:
				edt.windowsAction.setShortcut(QApplication.translate("MainWindow", "Ctrl+"+str(n), None, QApplication.UnicodeUTF8)) 
			n=n+1

		# save before close
		if isinstance(editor, Editor):
			currentText = editor.text()#open(editor.path).read()
			if self.textBefores[index] != currentText:
				if editor.text_status == 2: #TEXT_CHANGED
					msg = QMessageBox()
					msg.setText('The file "' + editor.path + '" changed.')
					msg.setInformativeText('If you don\'t save it, the changes will be permanently lost.')
					msg.setStandardButtons(QMessageBox.Save | QMessageBox.Cancel)
					msg.addButton("Close without Saving" , QMessageBox.NoRole )
					msg.setDefaultButton(QMessageBox.Cancel)
					msg.setWindowTitle("Warning")
					ret = msg.exec_()

					if ret == QMessageBox.Save:
						self.textBefores[index] = editor.text()
						editor.text_status = 1 #TEXT_READ
						if editor.tempfile == False:
							editor.save()
						else:
							self.tabClosing = True 
							ret = self.main.saveas()
							self.tabClosing = False
							index = self.count() - 1
					elif ret == QMessageBox.Cancel:
						return 
					else:
						pass

		#close current index tab
		edt = self.editors.pop(index) #new
		self.windowsMenu.removeAction(edt.windowsAction)
		self.removeTab(index)
		self.paths.pop(index)

		if 0 == self.count():
			self.m.editorMenuEnabled(False)
			self.close()
			self.main.getEditorTabs().pop(self.main.getTabWidgetNumber(self))
				
    def changeTab(self, index):

		if index == -1:
			return 

		"""
		if hasattr(self.editors[index], "fileIndex") == True :
			if self.editors[index].fileIndex is not None:
				self.fileSystem.model.view.setSelectionMode(QAbstractItemView.SingleSelection)
				self.fileSystem.model.view.setCurrentIndex(self.editors[index].fileIndex)
			else:
				self.fileSystem.model.view.setSelectionMode(QAbstractItemView.NoSelection)
				#self.fileSystem.model.view.setCurrentIndex(None)
		else:
			self.fileSystem.model.view.setSelectionMode(QAbstractItemView.NoSelection)
			#self.fileSystem.model.view.setCurrentIndex(None)
		"""

		try :
			currentText = open(self.paths[index]).read()
		except :
			return

		if self.editors[index].tempfile == False :
			if self.textBefores[index] != currentText and self.tabClosing == False :
				msg = QMessageBox()
				msg.setText('The file "' + self.paths[index] + '" changed on disk.')
				if self.editors[index].text_status == 2: #TEXT_CHANGED
					msg.setInformativeText('Do you want to drop your changes and reload the file ?')
				else:
					msg.setInformativeText('Do you want to reload the file ?')
				msg.setStandardButtons(QMessageBox.Ok | QMessageBox.Cancel)
				msg.setDefaultButton(QMessageBox.Cancel)
				msg.setWindowTitle("Warning")
				ret = msg.exec_()

				if ret == QMessageBox.Ok:
    				# Reload 
					self.editors[index].readFile(self.paths[index])
					#print("YUGI4"+self.paths[index])
					self.textBefores[index] = self.editors[index].text()
					self.editors[index].text_status = 1 #TEXT_READ
					self.editors[index].save() # added 2/3
					self.textBefores[index] = self.editors[index].text() #added 2/3
		else:
			#print("[VDBG] YUGI3: "+self.paths[index])
			if self.tabClosing == False :
			    self.editors[index].readFile(self.paths[index])
			    self.textBefores[index] = self.editors[index].text()
			    self.editors[index].text_status = 1 #TEXT_READ
			    self.editors[index].save() # added 2/3
			    self.textBefores[index] = self.editors[index].text() #added 2/3
			    self.editors[index].tempfile = True
			else:
			    return

		self.setCurrentIndex(index)


"""
Subclass of dock to handle drag/drop events
"""
class EditorDock(QDockWidget):
    
    def __init__(self, main, parent = None):
        QDockWidget.__init__(self, parent)
        self.setAcceptDrops(True)
        self.setFeatures(QDockWidget.DockWidgetClosable)
        self.setObjectName("editorDock")

        sizePolicy = QSizePolicy(QSizePolicy.Preferred, QSizePolicy.Preferred)
        sizePolicy.setHorizontalStretch(0)
        sizePolicy.setVerticalStretch(0)
        sizePolicy.setHeightForWidth(self.sizePolicy().hasHeightForWidth())
        self.setSizePolicy(sizePolicy)
        self.setMinimumSize(QSize(215, 100))

        font = QFont()
        #font.setStyleHint(font.Inconsolata)
        #font.setFamily('Inconsolata')
        #if not font.exactMatch():
        font.setPointSize(10)
        self.setFont(font)

		# Set empty title bar widget to remove title bar space
        titleWidget = QWidget()
        self.setTitleBarWidget(titleWidget)

        self.main = main
        
    def dragEnterEvent(self, event):
        event.acceptProposedAction()
        
    def dropEvent(self, event):
        self.main.dropFileEvent(event, 'dock')
        
        #print('From', event.source(), event.mimeData().hasText())
        #if event.mimeData().hasText():
        #    event.acceptProposedAction()
        #    path = str(event.mimeData().urls()[0].path())
        #    self.main.newEditor(path)
        #elif event.source() == self.main.getFileSystemView():
        #    self.main.openInEditor(event.source().currentIndex())
        #else:
        #    print('Failed to open dropped file.')
        #    #self.main.openInEditor()
            #print(event.mimeData().urls())
            #self.main.getFileSystemModel().currentIndex()
