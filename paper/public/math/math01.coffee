source = document.querySelector('#source')
transl = document.querySelector('#transl')
output = document.querySelector('#output')

# alphabet = ["alpha","beta","chi","delta","Delta","epsilon","varepsilon","eta","gamma","Gamma","iota","kappa","lambda","Lambda","mu","nu","omega","Omega","phi","Phi","varphi","pi","Pi","psi","Psi","rho","sigma","Sigma","tau","theta","Theta","vartheta","upsilon","xi","Xi","zeta"]
alphabet = ["alpha","beta","delta","epsilon","gamma","kappa","lambda","mu","nu","omega","phi","pi","psi","sigma","tau","theta","zeta"]
fillers = ["x","y","z","i","j","k"]
o = null
equations = [
    [o, "=",o,";"]
    [o,"!=",o,";"]
    [o,"->",o,";"]
    [o,"=>",o,";"]
    [o,">",o,";"]
    [o,"<",o,";"]
    [o,">=",o,";"]
    [o,"<=",o,";"]
    [o," in ",o,";"]
    [o," !in ",o,";"]
    [o," sub ",o,";"]
    [o," sup ",o,";"]
    [o," ~= ",o,";"]
    [o," ~~ ",o,";"]
]

operators = [

    ["sqrt(",o,")"]
    ["sqrt(",o,"-",o,")"]
    ["root(",o,")(",o,"+-",o,")"]

    ["sum_(",o,"=",o,")^(",o,") ",o]
    ["prod_(",o,"=",o,")^(",o,") ",o]
    ["int_0^1 ",o," d ",o, " "]
    ["int ",o," d ",o, " "]
    ["oint ",o," d ",o, " "]
    ["lim_(",o,"->oo) ",o,"(",o,")"]
    ["lim_(",o,"->0) ",o]

    ["((",o,"|",o,")|(",o,"|",o,"))"]
    # ["((",o,"|",o,"|",o,")|(",o,"|",o,"|",o,")|(",o,"|",o,"|",o,"))"]   
    ["[[",o,"|",o,"]|[",o,"|",o,"]]"]
    # ["[[",o,"|",o,"|",o,"]|[",o,"|",o,"|",o,"]|[",o,"|",o,"|",o,"]]"]

    ["hat ", o]
    ["bar ", o]
    ["ul ", o]
    ["vec ", o]
    ["dot ", o]
    ["ddot ", o]

    [o,"^2"]
    [o,"^3"]
    ["e^(i",o," - ", o,") "]
    [o,"^(",o,")"]
    [o,"_(",o,")"]
    ["(",o,"-",o,")^(",o,")"]

    ["sin ", o]
    ["cos ", o]
    ["tan ", o]
    ["log_", o, " ", o]

    [o, " * ", o]

    ["(",o,")/(",o,")"]
    ["(",o,")/(",o,"+",o,")"]
    ["(",o," +- ",o,")/(",o,")"]
    ["(",o," + ",o,")/(",o,"+-",o,")"]
    ["(",o," +- ",o,")^(",o,")"]

]

translate = (text)->
    formula = []
    placeholders = []
    
    generatePlaceholders = (arr, c)->
        o = arr[c%arr.length].slice(0)
        for e,i in o
            # fetch placeholders
            if e is null
                e = o[i] = []
                placeholders.push e
        o
        
    for w,i in text
        c = w.charCodeAt 0

        if placeholders.length is 0
            # clone operator
            o = generatePlaceholders equations, c+i
            formula.push o
            
        else if i%2 is 0
            o = generatePlaceholders operators, c+i
            ph = placeholders.shift()
            ph[0] = o
        else
            ph = placeholders.shift()
            ph[0] = alphabet[(c+i)%alphabet.length]
            # ph[1] = "_i"
    
    # fill empty placeholder
    for ph, i in placeholders 
        ph[0] = fillers[i%fillers.length]+"_#{i}"

    formula.join().replace(/,/g,'').replace(/\|/g,',')
    





MathJax.Hub.Queue ()->
    math = MathJax.Hub.getAllJax("output")[0]
  
    updateFormula = ->
        MathJax.Hub.Queue(["Text", math, transl.value])
  
    source.addEventListener 'input', ()->
        transl.value = translate source.value
        updateFormula()
    transl.addEventListener 'input', updateFormula