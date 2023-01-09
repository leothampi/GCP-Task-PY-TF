obj = {}
obj = {'a': {'b': {'c': 'd'}}}
key = 'a'


def get_value_dict(obj, key):

    if (len(key) == 0):
        return ('Key not valid')
    else:
        # Split the key into a list of keys
        keys = key.split("/")
       # print (keys)
        # Initialize the value to the input dictionary
        value = obj
        if type(obj) is not dict :
            return "Dic not found"
        else :
            # Iterate through the keys and retrieve the value at each level
            for i in keys:
                value = value.get(i)
            ##print (value)
        # Return the final value
    return value

obj = {'a': {'b': {'c': 'd'}}}
key = "a"
value = get_value_dict(obj, key)
print(value)  

obj = { "x": { "y": { "z": "a" } } }
key = "x/y/z"
value = get_value_dict(obj, key)
print(value) 