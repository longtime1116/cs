class intSet(object):
    """An intSet is a set of integers
    The value is represented by a list of ints, self.vals.
    Each int in the set occurs in self.vals exactly once."""

    def __init__(self):
        """Create an empty set of integers"""
        self.vals = []

    def __str__(self):
        """Returns a string representation of self"""
        self.vals.sort()
        return '{' + ','.join([str(e) for e in self.vals]) + '}'

    def __len__(self):
        return len(self.vals)

    def insert(self, e):
        """Assumes e is an integer and inserts e into self"""
        if not e in self.vals:
            self.vals.append(e)

    def member(self, e):
        """Assumes e is an integer
           Returns True if e is in self, and False otherwise"""
        return e in self.vals

    def remove(self, e):
        """Assumes e is an integer and removes e from self
           Raises ValueError if e is not in self"""
        try:
            self.vals.remove(e)
        except:
            raise ValueError(str(e) + ' not found')

    def intersect(self, other):
        values =  [x for x in self.vals if x in other.vals]
        result = intSet()
        for v in values:
            result.insert(v)
        return result

s1 = intSet()
s1.insert(1)
s1.insert(3)
s1.insert(5)
s1.insert(7)
s1.insert(9)
s1.insert(11)

s2 = intSet()
s2.insert(1)
s2.insert(1)
s2.insert(2)
s2.insert(3)
s2.insert(5)
s2.insert(8)

print(s1.intersect(s2))
print(len(s1))
