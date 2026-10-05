s = " this is a string "
len(s) # length of s -> 18
s.replace(" ","-") # Substitute spaces " " with dashes
s.count("s")# Count the number of "s"
t = s.split() # Split the string using spaces and make a list 
t = s.split(" is ") # Split the string using " is " and make a list out of it
t = s.strip() # remove trailing spaces
s.upper()
s.upper().strip() # can perform sequential operations
'WOrD'.lower() # can perform operations directy on a literal string 