import sys
import random
from PyQt5 import QtWidgets
from PyQt5.QtWidgets import QMessageBox
from pymongo import MongoClient
from project import Ui_MainWindow 

LNames = []

FNames = []

Subject = []

Point = [str(i) for i in range(101)]
ch = random.choice

client = MongoClient("mongodb://localhost:27017/")
db = client["university"]
collection = db["students"]

class MainApp(QtWidgets.QMainWindow):
    def __init__(self):
        super().__init__()
        self.ui = Ui_MainWindow()
        self.ui.setupUi(self)
        self.ui.pushButton.clicked.connect(self.add_records)      
        self.ui.pushButton_2.clicked.connect(self.search_record)  
        self.ui.pushButton_3.clicked.connect(self.update_record)  
        self.ui.pushButton_4.clicked.connect(self.remove_record)  
        self.ui.pushButton_5.clicked.connect(QtWidgets.QApplication.quit) 

    def add_records(self):
        collection.delete_many({})
        for i in range(10):
            record = {
                "Ident": i + 1,
                "LName": ch(LNames),
                "FName": ch(FNames),
                "Subject": ch(Subject),
                "Point": ch(Point)
            }
            collection.insert_one(record)
        QMessageBox.information(self, "Success", "10 random records added.")

    def search_record(self):
        id_text = self.ui.lineEdit.text().strip()
        lname = self.ui.lineEdit_2.text().strip()
        fname = self.ui.lineEdit_5.text().strip()
        subject = self.ui.lineEdit_4.text().strip()
        point = self.ui.lineEdit_3.text().strip()

        query = {}
        if id_text.isdigit():
            query["Ident"] = int(id_text)
        if lname:
            query["LName"] = {"$regex": lname, "$options": "i"}
        if fname:
            query["FName"] = {"$regex": fname, "$options": "i"}
        if subject:
            query["Subject"] = {"$regex": subject, "$options": "i"}
        if point:
            query["Point"] = {"$regex": point, "$options": "i"}
        if not query:
            return  

        results = list(collection.find(query))

        if results:
            r = results[0]
            self.ui.lineEdit.setText(str(r.get("Ident", "")))
            self.ui.lineEdit_2.setText(r.get("LName", ""))
            self.ui.lineEdit_5.setText(r.get("FName", ""))
            self.ui.lineEdit_4.setText(r.get("Subject", ""))
            self.ui.lineEdit_3.setText(r.get("Point", ""))
        else:
            self.ui.lineEdit.setText("")
            self.ui.lineEdit_2.setText("")
            self.ui.lineEdit_5.setText("")
            self.ui.lineEdit_4.setText("")
            self.ui.lineEdit_3.setText("")
            QMessageBox.warning(self, "Not Found", "No such Record found.")

    def update_record(self):
        id_text = self.ui.lineEdit.text().strip()

        if not id_text.isdigit():
            QMessageBox.information(self, "Not Found", f"Record with ID {ident} Not Found.")

        ident = int(id_text)
        new_data = {
            "LName": self.ui.lineEdit_2.text().strip(),
            "FName": self.ui.lineEdit_5.text().strip(),
            "Subject": self.ui.lineEdit_4.text().strip(),
            "Point": self.ui.lineEdit_3.text().strip()
        }

        result = collection.update_one({"Ident": ident}, {"$set": new_data})

        if result.matched_count:
            QMessageBox.information(self, "Updated", f"Record with ID {ident} updated.")
        else:
            QMessageBox.warning(self, "Not Found", f"No record with ID {ident} found.")

    def remove_record(self):
        id_text = self.ui.lineEdit.text().strip()

        if not id_text.isdigit():
            return

        ident = int(id_text)
        result = collection.delete_one({"Ident": ident})

        if result.deleted_count:
            self.ui.lineEdit.setText("")
            self.ui.lineEdit_2.setText("")
            self.ui.lineEdit_5.setText("")
            self.ui.lineEdit_4.setText("")
            self.ui.lineEdit_3.setText("")
            QMessageBox.information(self, "Deleted", f"Record with ID {ident} deleted.")
        else:
            QMessageBox.warning(self, "Not Found", f"No record with ID {ident} found.")

if __name__ == "__main__":
    app = QtWidgets.QApplication(sys.argv)
    window = MainApp()
    window.show()
    sys.exit(app.exec_())
