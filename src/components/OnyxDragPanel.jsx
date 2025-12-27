import React from 'react';
import PropTypes from 'prop-types';
import { Onyx, OnyxDragContext, OnyxDragHandle } from 'onyx-library';

/**
 * This component represents a drag-and-drop panel using the Onyx framework.
 */
const OnyxDragPanel = ({ id, children, className, style }) => {
    return (
        <OnyxDragContext>
            <div id={id} className={`onyx-drag-panel ${className}`} style={style}>
                <OnyxDragHandle className="onyx-drag-handle" />
                {children}
            </div>
        </OnyxDragContext>
    );
};

OnyxDragPanel.propTypes = {
    id: PropTypes.string.isRequired,
    children: PropTypes.node,
    className: PropTypes.string,
    style: PropTypes.object,
};

OnyxDragPanel.defaultProps = {
    children: null,
    className: '',
    style: {},
};

export default OnyxDragPanel;