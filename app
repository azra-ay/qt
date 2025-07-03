import tkinter as tk
from tkinter import ttk, messagebox
from pymongo import MongoClient
import random

client = MongoClient("mongodb://localhost:27017/")
db = client.student_records
collection = db.students

LNames = ['Smith', 'Johnson', 'Williams', 'Jones', 'Brown', 'Davis', 'Miller', 'Wilson', 'Moore', 'Taylor']
FNames = ['Emma', 'Olivia', 'Ava', 'Isabella', 'Sophia', 'Amelia', 'Mia', 'Charlotte', 'Liam', 'Noah', 'William', 'James', 'Oliver']

Subjects = ['Art History', 'Psychology', 'World Literature', 'Sociology', 'Philosophy', 'Environmental Science', 'Political Theory', 'Cultural Studies', 'Media Ethics', 'Creative Writing']

Points = [str(i) for i in range(101)]
ch = random.choice

class StudentApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Student Records")
        
        tk.Label(self.root, text="ID").grid(row=0, column=0, padx=5, pady=5, sticky='e')
        self.id_entry = tk.Entry(self.root)
        self.id_entry.grid(row=0, column=1, padx=5, pady=5, sticky='w')
        
        self.add_btn = tk.Button(self.root, text="Add all records", command=self.add_records)
        self.add_btn.grid(row=0, column=2, padx=5, pady=5)

        tk.Label(self.root, text="Last Name").grid(row=1, column=0, padx=5, pady=5, sticky='e')
        self.lname_entry = tk.Entry(self.root)
        self.lname_entry.grid(row=1, column=1, padx=5, pady=5, sticky='w')
        
        self.search_btn = tk.Button(self.root, text="Search", command=self.search_records)
        self.search_btn.grid(row=1, column=2, padx=5, pady=5)

        tk.Label(self.root, text="Name").grid(row=2, column=0, padx=5, pady=5, sticky='e')
        self.fname_entry = tk.Entry(self.root)
        self.fname_entry.grid(row=2, column=1, padx=5, pady=5, sticky='w')
        
        self.update_btn = tk.Button(self.root, text="Update", command=self.update_record)
        self.update_btn.grid(row=2, column=2, padx=5, pady=5)

        tk.Label(self.root, text="Subject").grid(row=3, column=0, padx=5, pady=5, sticky='e')
        self.subject_entry = tk.Entry(self.root)
        self.subject_entry.grid(row=3, column=1, padx=5, pady=5, sticky='w')
        
        self.remove_btn = tk.Button(self.root, text="Remove", command=self.remove_record)
        self.remove_btn.grid(row=3, column=2, padx=5, pady=5)

        tk.Label(self.root, text="Grade").grid(row=4, column=0, padx=5, pady=5, sticky='e')
        self.grade_entry = tk.Entry(self.root)
        self.grade_entry.grid(row=4, column=1, padx=5, pady=5, sticky='w')
        
        self.close_btn = tk.Button(self.root, text="Close", command=self.root.quit)
        self.close_btn.grid(row=4, column=2, padx=5, pady=5)

        self.tree = ttk.Treeview(self.root, columns=('ID', 'Last Name', 'Name', 'Subject', 'Grade'), show='headings')
        self.tree.grid(row=5, column=0, columnspan=3, padx=5, pady=5, sticky='nsew')
        
        self.tree.heading('ID', text='ID')
        self.tree.heading('Last Name', text='Last Name')
        self.tree.heading('Name', text='Name')
        self.tree.heading('Subject', text='Subject')
        self.tree.heading('Grade', text='Grade')
        
        self.tree.column('ID', width=50)
        self.tree.column('Last Name', width=150)
        self.tree.column('Name', width=100)
        self.tree.column('Subject', width=200)
        self.tree.column('Grade', width=50)
        
        self.tree.bind('<<TreeviewSelect>>', self.on_tree_select)
        
        self.load_records()
    
    def on_tree_select(self, event):
        selected = self.tree.focus()
        if selected:
            values = self.tree.item(selected, 'values')
            self.id_entry.delete(0, tk.END)
            self.id_entry.insert(0, values[0])
            self.lname_entry.delete(0, tk.END)
            self.lname_entry.insert(0, values[1])
            self.fname_entry.delete(0, tk.END)
            self.fname_entry.insert(0, values[2])
            self.subject_entry.delete(0, tk.END)
            self.subject_entry.insert(0, values[3])
            self.grade_entry.delete(0, tk.END)
            self.grade_entry.insert(0, values[4])
    
    def load_records(self):
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        for record in collection.find():
            self.tree.insert('', 'end', values=(
                str(record['_id']),
                record['last_name'],
                record['first_name'],
                record['subject'],
                record['grade']
            ))
    
    def add_records(self):
        for _ in range(10):
            record = {
                'last_name': ch(LNames),
                'first_name': ch(FNames),
                'subject': ch(Subjects),
                'grade': ch(Points)
            }
            collection.insert_one(record)
        
        messagebox.showinfo("Success", "10 random student records added")
        self.load_records()
    
    def search_records(self):
        query = {}
        if self.id_entry.get():
            query['_id'] = self.id_entry.get()
        if self.lname_entry.get():
            query['last_name'] = {'$regex': f'.*{self.lname_entry.get()}.*', '$options': 'i'}
        if self.fname_entry.get():
            query['first_name'] = {'$regex': f'.*{self.fname_entry.get()}.*', '$options': 'i'}
        if self.subject_entry.get():
            query['subject'] = {'$regex': f'.*{self.subject_entry.get()}.*', '$options': 'i'}
        if self.grade_entry.get():
            query['grade'] = self.grade_entry.get()
        
        for item in self.tree.get_children():
            self.tree.delete(item)
        
        for record in collection.find(query):
            self.tree.insert('', 'end', values=(
                str(record['_id']),
                record['last_name'],
                record['first_name'],
                record['subject'],
                record['grade']
            ))
    
    def update_record(self):
        selected = self.tree.focus()
        if not selected:
            messagebox.showwarning("Warning", "Please select a record to update")
            return
        
        try:
            collection.update_one(
                {'_id': self.id_entry.get()},
                {'$set': {
                    'last_name': self.lname_entry.get(),
                    'first_name': self.fname_entry.get(),
                    'subject': self.subject_entry.get(),
                    'grade': self.grade_entry.get()
                }}
            )
            messagebox.showinfo("Success", "Record updated successfully")
            self.load_records()
        except Exception as e:
            messagebox.showerror("Error", f"Failed to update record: {str(e)}")
    
    def remove_record(self):
        selected = self.tree.focus()
        if not selected:
            messagebox.showwarning("Warning", "Please select a record to remove")
            return
        
        if messagebox.askyesno("Confirm", "Are you sure you want to delete this record?"):
            try:
                collection.delete_one({'_id': self.id_entry.get()})
                messagebox.showinfo("Success", "Record removed successfully")
                self.clear_fields()
                self.load_records()
            except Exception as e:
                messagebox.showerror("Error", f"Failed to remove record: {str(e)}")
    
    def clear_fields(self):
        self.id_entry.delete(0, tk.END)
        self.lname_entry.delete(0, tk.END)
        self.fname_entry.delete(0, tk.END)
        self.subject_entry.delete(0, tk.END)
        self.grade_entry.delete(0, tk.END)

if __name__ == "__main__":
    root = tk.Tk()
    app = StudentApp(root)
    root.mainloop()
