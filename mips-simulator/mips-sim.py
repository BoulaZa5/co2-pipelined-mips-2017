from tkinter import *
from tkinter.ttk import *
import tkinter.filedialog as fdialog
import tkinter.messagebox as msgbox
from ttkthemes import ThemedStyle

from assemblerParser import assembly_parser
from InstructionTable import instruction_table
from RegisterTable import register_table

import subprocess
import os
import time

import tempfile


ICON = (b'\x00\x00\x01\x00\x01\x00\x10\x10\x00\x00\x01\x00\x08\x00h\x05\x00\x00'
        b'\x16\x00\x00\x00(\x00\x00\x00\x10\x00\x00\x00 \x00\x00\x00\x01\x00'
        b'\x08\x00\x00\x00\x00\x00@\x05\x00\x00\x00\x00\x00\x00\x00\x00\x00\x00'
        b'\x00\x01\x00\x00\x00\x01') + b'\x00'*1282 + b'\xff'*64
_, ICON_PATH = tempfile.mkstemp()
with open(ICON_PATH, 'wb') as icon_file:
    icon_file.write(ICON)


def addToReturnTextbox(text):
    returnTextBox.configure(state='normal')
    returnTextBox.insert('end', text + '\n')
    returnTextBox.configure(state='disabled')
    labelText(text)


def labelText(labelTxt):
    statusBar.config(text=labelTxt)


def clearASM():
    if assemblyTextBox.get("1.0", END) != "\n":
        saveAsASM()
        assemblyTextBox.delete('1.0', END)
    if returnTextBox.get("1.0", END) != "\n":
        returnTextBox.delete('1.0', END)


def openASM():
    if assemblyTextBox.get("1.0", END) == "\n":
        ASMFile = fdialog.askopenfile(filetypes=[("Assembly Code", "*.asm")])
        assemblyCode = ASMFile.read()
        assemblyTextBox.delete('1.0', END)
        assemblyTextBox.insert(END, assemblyCode)
        ASMFile.close()
    else:
        answer = msgbox.askquestion('Alert', 'You have some unsaved assembly code\nDo you want to save it before you import another file?')
        if answer == 'yes':
            saveAsASM()
            assemblyTextBox.delete('1.0', END)
            openASM()
        else:
            ASMFile = fdialog.askopenfile(filetypes=[("Assembly Code", "*.asm")])
            assemblyCode = ASMFile.read()
            assemblyTextBox.delete('1.0', END)
            assemblyTextBox.insert(END, assemblyCode)
            ASMFile.close()
    if returnTextBox.get("1.0", END) != "\n":
        returnTextBox.delete('1.0', END)


def saveAsASM():
    assemblyCode = assemblyTextBox.get("1.0", "end-1c")
    savelocation = fdialog.asksaveasfilename(filetypes=[("Assembly Code", "*.asm")])
    ASMFile = open(savelocation + ".asm", "w+")
    ASMFile.write(assemblyCode)
    ASMFile.close()


def exitApp():
    if assemblyTextBox.get("1.0", END) == "\n":
        mainApp.quit()
    else:
        answer = msgbox.askquestion('Alert', 'You have some unsaved assembly code\nDo you want to save it before you exit?')
        if answer == 'yes':
            saveAsASM()
            mainApp.quit()
        else :
            mainApp.quit()


def undoASM():
    assemblyTextBox.event_generate("<<Undo>>")


def redoASM():
    assemblyTextBox.event_generate("<<Redo>>")


def cutASM():
    assemblyTextBox.event_generate("<<Cut>>")


def copyASM():
    assemblyTextBox.event_generate("<<Copy>>")


def pasteASM():
    assemblyTextBox.event_generate("<<Paste>>")


def selectAllASM():
    assemblyTextBox.tag_add("sel",'1.0','end')


def upload():
    assemblyCode = assemblyTextBox.get("1.0", "end-1c")
    ASMFile = open("sim.asm", "w")
    ASMFile.write(assemblyCode)
    ASMFile.close()
    addToReturnTextbox("Parsing Assembly...")
    convertTohex()
    addToReturnTextbox("Parsing Assembly Successful")
    addToReturnTextbox("Simulating...")
    simulate()
    addToReturnTextbox("Simulating Successful")


def openExampleOne():
    if assemblyTextBox.get("1.0", END) == "\n":
        addToReturnTextbox("Opening example one...")
        ASMFile = open("examples/example1.asm", "r")
        assemblyCode = ASMFile.read()
        assemblyTextBox.delete('1.0', END)
        assemblyTextBox.insert(END, assemblyCode)
        ASMFile.close()
        addToReturnTextbox("Opening example one Successful")
    else:
        answer = msgbox.askquestion('Alert', 'You have some unsaved assembly code\nDo you want to save it before you import the example?')
        if answer == 'yes':
            saveAsASM()
            assemblyTextBox.delete('1.0', END)
            openExampleOne()
        else:
            assemblyTextBox.delete('1.0', END)
            openExampleOne()


def openExampleTwo():
    if assemblyTextBox.get("1.0", END) == "\n":
        addToReturnTextbox("Opening example two...")
        ASMFile = open("examples/example2.asm", "r")
        assemblyCode = ASMFile.read()
        assemblyTextBox.delete('1.0', END)
        assemblyTextBox.insert(END, assemblyCode)
        ASMFile.close()
        addToReturnTextbox("Opening example two Successful")
    else:
        answer = msgbox.askquestion('Alert', 'You have some unsaved assembly code\nDo you want to save it before you import the example?')
        if answer == 'yes':
            saveAsASM()
            assemblyTextBox.delete('1.0', END)
            openExampleTwo()
        else:
            assemblyTextBox.delete('1.0', END)
            openExampleTwo()


def openExampleThree():
    if assemblyTextBox.get("1.0", END) == "\n":
        addToReturnTextbox("Opening example three...")
        ASMFile = open("examples/example3.asm", "r")
        assemblyCode = ASMFile.read()
        assemblyTextBox.delete('1.0', END)
        assemblyTextBox.insert(END, assemblyCode)
        ASMFile.close()
        addToReturnTextbox("Opening example three Successful")
    else:
        answer = msgbox.askquestion('Alert', 'You have some unsaved assembly code\nDo you want to save it before you import the example?')
        if answer == 'yes':
            saveAsASM()
            assemblyTextBox.delete('1.0', END)
            openExampleThree()
        else :
            assemblyTextBox.delete('1.0', END)
            openExampleThree()


def memoryMonitor():
    MemoryMonitor = Tk()
    appStyle = ThemedStyle(MemoryMonitor)
    appStyle.set_theme("plastik")
    MemoryMonitor.iconbitmap(default=ICON_PATH)
    MemoryMonitor.title("Memory Monitor")
    MemoryMonitor.resizable(width=False, height=False)
    MemoryMonitor.minsize(width=570, height=510)
    MemoryMonitor.mainloop()


def aboutUs():
    about = Tk()
    abtStyle = ThemedStyle(about)
    abtStyle.set_theme("clearlooks")
    about.iconbitmap(default=ICON_PATH)
    about.title("About")
    about.resizable(width=False, height=False)
    about.resizable(width=1, height=1)
    abtLabel1 = Label(about, text="This program was created by Boula Nashat, Peter Rateb, Beshoy Anwar \nand Menna'tallah Mohamed to simulate a mips processor.")
    abtLabel1.pack(padx=5, pady=5)
    about.withdraw()
    about.update_idletasks()
    x = (about.winfo_screenwidth() - about.winfo_reqwidth()) / 2
    y = (about.winfo_screenheight() - about.winfo_reqheight()) / 2
    about.geometry("+%d+%d" % (x, y))
    about.deiconify()
    about.mainloop()


def convertTohex():
    assembly = open("sim.asm", 'r')
    lines = assembly.readlines()
    assembly.close()
    parser = assembly_parser(0, instruction_table, register_table, 4)
    parser.first_pass(lines)
    parser.second_pass(lines)


def replaceClk():
    halfClk = clkTextbox.get()
    with open('mips-std.v', 'r') as file:
        filedata = file.read()
    clk = int(halfClk) * 2
    filedata = filedata.replace('<<TIME>>', str(clk))
    with open('mips.v', 'w') as file:
        file.write(filedata)


def simulate():
    #Get clk value
    replaceClk()
    time.sleep(2)
    #This just compiles the .v
    subprocess.Popen(['iverilog\\bin\\iverilog', 'mips.v'])
    time.sleep(2)
    #this opens the simulator
    outfile = open('out.p', 'w');
    subprocess.Popen(['iverilog\\bin\\vvp', 'a.out'], bufsize=0, stdout=outfile)
    outfile.close()
    time.sleep(5)
    infile = open('out.p', 'r');
    data = infile.read()
    infile.close()
    data = data.replace('WARNING: mips.v:439: $readmemh(out.hex): Not enough words in the file for the requested range [0:1023].', '')
    data = data.replace('reg 0', '$zero')
    data = data.replace('reg 1', '$at        ')
    data = data.replace('reg 2', '$v0        ')
    data = data.replace('reg 3', '$v1        ')
    data = data.replace('reg 4', '$a0        ')
    data = data.replace('reg 5', '$a1        ')
    data = data.replace('reg 6', '$a2        ')
    data = data.replace('reg 7', '$a3        ')
    data = data.replace('reg 8', '$t0        ')
    data = data.replace('reg 9', '$t1        ')
    data = data.replace('reg10', '$t2        ')
    data = data.replace('reg11', '$t3        ')
    data = data.replace('reg12', '$t4        ')
    data = data.replace('reg13', '$t5        ')
    data = data.replace('reg14', '$t6        ')
    data = data.replace('reg15', '$t7        ')
    data = data.replace('reg16', '$s0        ')
    data = data.replace('reg17', '$s1        ')
    data = data.replace('reg18', '$s2        ')
    data = data.replace('reg19', '$s3        ')
    data = data.replace('reg20', '$s4        ')
    data = data.replace('reg21', '$s5        ')
    data = data.replace('reg22', '$s6        ')
    data = data.replace('reg23', '$s7        ')
    data = data.replace('reg24', '$t8        ')
    data = data.replace('reg25', '$t9        ')
    data = data.replace('reg26', '$k0        ')
    data = data.replace('reg27', '$k1        ')
    data = data.replace('reg28', '$gp        ')
    data = data.replace('reg29', '$sp        ')
    data = data.replace('reg30', '$fp        ')
    data = data.replace('reg31', '$ra        ')

    #proc = subprocess.check_output(['iverilog\\bin\\vvp.exe', 'a.out'], shell=True)
    addToReturnTextbox(data)
    os.remove("a.out")


#Main App
mainApp = Tk()
appStyle = ThemedStyle(mainApp)
appStyle.set_theme("plastik")
mainApp.iconbitmap(default=ICON_PATH)
mainApp.title("MIPS Simulator")
mainApp.resizable(width=False, height=False)
mainApp.minsize(width=570, height=510)
#Menu Bar
menuBar = Menu(mainApp)
mainApp.config(menu=menuBar)
fileMenu = Menu(menuBar)
menuBar.add_cascade(label="File", menu=fileMenu)
fileMenu.add_command(label="Start a new assembly code", command=clearASM)
fileMenu.add_separator()
fileMenu.add_command(label="Open some previous assembly code", command=openASM)
fileMenu.add_command(label="Save this assembly code", command=saveAsASM)
fileMenu.add_separator()
fileMenu.add_command(label="Exit", command=exitApp)
editMenu = Menu(menuBar)
menuBar.add_cascade(label="Edit", menu=editMenu)
editMenu.add_command(label="Undo", command=undoASM)
editMenu.add_command(label="Redo", command=redoASM)
editMenu.add_separator()
editMenu.add_command(label="Cut", command=cutASM)
editMenu.add_command(label="Copy", command=copyASM)
editMenu.add_command(label="Paste", command=pasteASM)
editMenu.add_separator()
editMenu.add_command(label="Select All", command=selectAllASM)
sketchMenu = Menu(menuBar)
menuBar.add_cascade(label="Sketch", menu=sketchMenu)
sketchMenu.add_command(label="Upload", command=upload)
#sketchMenu.add_separator()
#codeExamples = Menu(sketchMenu)
#sketchMenu.add_cascade(label="Examples", menu=codeExamples)
#codeExamples.add_command(label="1. Simple", command=openExampleOne)
#codeExamples.add_command(label="2. Moderate", command=openExampleTwo)
#codeExamples.add_command(label="3. Advanced", command=openExampleThree)
#toolsMenu = Menu(menuBar)
#menuBar.add_cascade(label="Tools", menu=toolsMenu)
#toolsMenu.add_command(label="Memory Monitor", command=memoryMonitor)
helpMenu = Menu(menuBar)
menuBar.add_cascade(label="Help", menu=helpMenu)
helpMenu.add_command(label="About", command=aboutUs)
#Toolbar
toolBar = Frame(mainApp)
toolBar.pack(side=TOP, fill=X)
clkLabel = Label(toolBar, text="clk #")
clkLabel.pack(side=LEFT, padx=25, pady=2)
v = StringVar(toolBar, value='250')
clkTextbox = Entry(toolBar, textvariable=v, width=10)
clkTextbox.pack(side=LEFT, padx=2, pady=2)
uploadImg = PhotoImage(file="ic_file_upload_black_24dp_1x.png")
uploadBtn = Button(toolBar, text="Upload", image=uploadImg, command=upload)
uploadBtn.pack(side=LEFT, padx=50, pady=2)
newImg = PhotoImage(file="ic_create_new_folder_black_24dp_1x.png")
newBtn = Button(toolBar, text="New", image=newImg, command=clearASM)
newBtn.pack(side=LEFT, padx=2, pady=2)
openImg = PhotoImage(file="ic_open_in_new_black_24dp_1x.png")
openBtn = Button(toolBar, text="Open", image=openImg, command=openASM)
openBtn.pack(side=LEFT, padx=2, pady=2)
saveImg = PhotoImage(file="ic_save_black_24dp_1x.png")
saveBtn = Button(toolBar, text="Save", image=saveImg, command=saveAsASM)
saveBtn.pack(side=LEFT, padx=2, pady=2)

#Status Bar
statusBar = Label(mainApp, text="Doing Nothing...", relief=SUNKEN, anchor=W)
statusBar.pack(side=BOTTOM, fill=X)

#Main Assembly Editor
assemblyFrame = Frame(mainApp, width=550, height=400)
assemblyFrame.pack(fill="both", expand=True)
assemblyFrame.grid_propagate(False)
assemblyFrame.grid_rowconfigure(0, weight=1)
assemblyFrame.grid_columnconfigure(0, weight=1)
assemblyTextBox = Text(assemblyFrame, borderwidth=1)
assemblyTextBox.config(font=("Helvetica", 12), undo=True, wrap='word')
assemblyTextBox.grid(row=0, column=0, sticky="nsew", padx=0, pady=10)
assemblyScroller = Scrollbar(assemblyFrame, command=assemblyTextBox.yview)
assemblyScroller.grid(row=0, column=1, sticky="nsew")
assemblyTextBox['yscrollcommand'] = assemblyScroller.set

#Command Prompt
returnFrame = Frame(mainApp, width=550, height=200)
returnFrame.pack(fill="both", expand=True)
returnFrame.grid_propagate(False)
returnFrame.grid_rowconfigure(0, weight=1)
returnFrame.grid_columnconfigure(0, weight=1)
returnTextBox = Text(returnFrame, borderwidth=1)
returnTextBox.config(font=("Helvetica", 12), state=DISABLED, wrap='word')
returnTextBox.grid(row=0, column=0, sticky="nsew", padx=0, pady=10)
returnScroller = Scrollbar(returnFrame, command=returnTextBox.yview)
returnScroller.grid(row=0, column=1, sticky="nsew")
returnTextBox['yscrollcommand'] = returnScroller.set

mainApp.withdraw()
mainApp.update_idletasks()
x = mainApp.winfo_screenwidth()/2 - ((mainApp.winfo_screenwidth() - mainApp.winfo_reqwidth()) / 2)
y = mainApp.winfo_screenheight()/2 - ((mainApp.winfo_screenheight() - mainApp.winfo_reqheight()) / 2)
mainApp.geometry("+%d+%d" % (x, y))
mainApp.deiconify()
mainApp.mainloop()