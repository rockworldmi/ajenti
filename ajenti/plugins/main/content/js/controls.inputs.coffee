class window.Controls.textbox extends window.Control
    createDom: () ->
        @dom = $("""
            <div>
                <input class="control textbox #{@properties.style}" 
                    type="text" 
                    value="#{@properties.value or ''}" />
            </div>
        """)
        @input = @dom.find('input')

    detectUpdates: () ->
        r = {}
        value = @input.val()
        if @properties.type == 'integer'
            value = parseInt(value)
        if value != @properties.value
            r.value = value
        @properties.value = value
        return r


class window.Controls.editable extends window.Control
    createDom: () ->
        icon = _make_icon(@properties.icon)
        @dom = $("""
            <div class="control editable">
                <div class="control label">#{icon} <span>#{@properties.placeholder ? @properties.value}</span></div>
                <input class="control textbox" type="text" value="#{@properties.value or ''}" />
            </div>
        """)
        @label = @dom.find('.label')
        @input = @dom.find('input')
        @input.hide()
        @label.click @goEditMode
        @input.blur @goViewMode
        @input.keyup (e) =>
            if e.which == 13
                @goViewMode()
            @cancel(e)

    goViewMode: () =>
        @label.find('>span').html(@properties.placeholder ? @input.val())
        @input.hide()
        @label.show()

    goEditMode: (e) =>
        @label.hide()
        @input.show()
        @input.focus()
        e.stopPropagation()
        e.preventDefault()

    detectUpdates: () ->
        r = {}
        value = @input.val()
        if @properties.type == 'integer'
            value = parseInt(value)
        if value != @properties.value
            r.value = value
        return r


class window.Controls.checkbox extends window.Control
    createDom: () ->
        @dom = $("""
            <div class="control checkbox">
                <input 
                    id="#{@properties.uid}"
                    type="checkbox" 
                    #{if @properties.value then 'checked="checked"' else ''} 
                />
                <label for="#{@properties.uid}">
                    <div class="tick">
                        <i class="icon-ok"></i>
                    </div>
                </label>
                <div class="control label">#{@properties.text}</div>
            </div>
        """)
        @input = @dom.find('input')

    detectUpdates: () ->
        r = {}
        checked = @input.is(':checked')
        if checked != @properties.value
            r.value = checked
        @properties.value = checked
        return r


class window.Controls.dropdown extends window.Control
    createDom: () ->
        @dom = $("""
            <div><select class="control dropdown" /></div>
        """)
        @input = @dom.find('select')
        @data = []
        for i in [0...@properties.labels.length]
            do (i) =>
                @input.append("""<option value="#{@properties.values[i]}" #{if @properties.values[i] == @properties.value then 'selected' else ''}>#{@properties.labels[i]}</option>""")

        @input.select2()
        
        if @properties.server
            @input.change (e) =>
                @event('change', {})
                @cancel(e)

    detectUpdates: () ->
        r = {}
        value = @input.val()
        if @properties.type == 'integer'
            value = parseInt(value)
        if value != @properties.value
            r.value = value
        @properties.value = value
        return r


class window.Controls.combobox extends window.Control
    createDom: () ->
        @dom = $("""
            <div><input class="control combobox" type="text" value="#{@properties.value}" /></div>
        """)
        @input = @dom.find('input')
        @data = []
        for i in [0...@properties.labels.length]
            do (i) =>
                @data.push {label: @properties.labels[i], value: @properties.values[i]}

        if @properties.separator != null
            @input.autocomplete {
                source: (request, response) =>
                    vals = @getVals()
                    response($.ui.autocomplete.filter(@data, vals.pop()))
                focus: () =>
                    return false
                select: (event, ui) =>
                    vals = @getVals()
                    vals.pop()
                    vals.push ui.item.value
                    @input.val(vals.join(@properties.separator))
                    return false
                minLength: 0
            }
        else
            @input.autocomplete source: @data, minLength: 0
        @input.click () =>
            @input.autocomplete 'search', ''

    getVals: () ->
        return @input.val().split(@properties.separator)

    detectUpdates: () ->
        r = {}
        value = @input.val()
        if @properties.type == 'integer'
            value = parseInt(value)
        if value != @properties.value
            r.value = value
        @properties.value = value
        return r



class window.Controls.fileupload extends window.Control
    createDom: () ->
        @dom = $("""
            <div class="control fileupload">
                <input type="file" />
                
                <div class="full-overlay">
                    <div class="content">
                        <div class="inner">
                            <h1>Upload</h1>
                            <div class="pb"></div>
                        </div>
                    </div>
                </div>  
            </div>
        """)
        @progress = new window.Controls.progressbar(@ui, {}, [])
        @dom.find('.pb').append($(@progress.dom))
        @input = @dom.find('input')[0]
        @input.addEventListener 'change', (e) =>
            file = @input.files[0]
            xhr = new XMLHttpRequest()
            xhr.file = file
            
            if xhr.upload
                xhr.upload.onprogress = (e) =>
                    done = e.position || e.loaded
                    total = e.totalSize || e.total
                    progress = 1.0 * done / total / 2
                    @progress.setProgress(progress)

            d = new FormData()
            d.append('file', file)

            xhr.open('post', @properties.target, true)
            xhr.send(d)
            $(@dom).find('.full-overlay').show()
        , false
        @dom.find('.full-overlay').hide()
